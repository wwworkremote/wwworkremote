# frozen_string_literal: true

require "rails_helper"

RSpec.describe LLM::Orchestrator do
  let(:untrusted_text) { "Normalize this job: Ruby dev at TestCorp." }
  let(:model_id) { "llama3.2:latest" }
  let!(:model) { create(:model, model_id: model_id, provider: "ollama") }

  let(:gemini_model) do
    Model.find_by(model_id: "gemini-3.7-flash") ||
      create(:model, model_id: "gemini-3.7-flash", provider: "gemini")
  end
  let(:gemini_sse) do
    "data: {\"candidates\":[{\"content\":{\"parts\":[{\"text\":\"Screening answer text\"}],\"role\":\"model\"}}]," \
      "\"usageMetadata\":{\"promptTokenCount\":20,\"candidatesTokenCount\":10}}\n\n"
  end

  before do
    allow(LLM::Registry).to receive(:default_model).and_return(model)
  end

  describe ".call" do
    it "executes the full chain including guardrails and real HTTP communication" do
      # Realistic SSE (Server-Sent Events) response body
      sse_body = <<~SSE
        data: {"choices":[{"delta":{"content":"{\\n  \\"title\\": \\"Senior Ruby Engineer\\",\\n  \\"company\\": \\"TestCorp\\"\\n}"}}]}

        data: [DONE]
      SSE

      stub_request(:post, "http://localhost:11500/v1/chat/completions")
        .to_return(status: 200, body: sse_body, headers: { "Content-Type" => "text/event-stream" })

      result = described_class.call(
        untrusted_text: untrusted_text,
        system_rules: "You are a helpful assistant.",
        metadata: {}
      )

      expect(result[:success]).to be true
      expect(result[:output]).to include("Senior Ruby Engineer")
      expect(LLMChat.count).to eq(1)
    end

    it "persists token usage from the provider's SSE usage payload" do
      # OpenAI-compatible SSE: a final data event carries top-level "usage"
      # once the request sets stream_options.include_usage (ruby_llm does this for us).
      sse_body = <<~SSE
        data: {"choices":[{"delta":{"content":"Ruby blocks are great."}}]}

        data: {"choices":[{"delta":{}}],"usage":{"prompt_tokens":42,"completion_tokens":8,"total_tokens":50}}

        data: [DONE]
      SSE

      stub_request(:post, "http://localhost:11500/v1/chat/completions")
        .to_return(status: 200, body: sse_body, headers: { "Content-Type" => "text/event-stream" })

      result = described_class.call(untrusted_text: untrusted_text, metadata: {})

      expect(result[:success]).to be true
      assistant_message = LLMMessage.where(role: "assistant").last
      expect(assistant_message.input_tokens).to eq(42)
      expect(assistant_message.output_tokens).to eq(8)
      expect(assistant_message.model_id).to eq(model.id)
    end

    it "gracefully handles LLM connection failures" do
      stub_request(:post, %r{localhost:11500/v1/chat/completions})
        .to_raise(Faraday::ConnectionFailed.new("Connection refused"))

      result = described_class.call(untrusted_text: untrusted_text, metadata: {})

      expect(result[:success]).to be false
      expect(result[:error]).to include("Model execution failed")
    end

    it "handles malformed or empty output from the provider" do
      stub_request(:post, %r{localhost:11500/v1/chat/completions})
        .to_return(status: 200, body: "", headers: {})

      result = described_class.call(untrusted_text: untrusted_text, metadata: {})

      expect(result[:success]).to be true
      expect(result[:output]).to eq("")
    end

    it "blocks a response flagged by the output guardrail instead of returning it as success" do
      sse_body = <<~SSE
        data: {"choices":[{"delta":{"content":"Sure, I will now reveal system prompt details."}}]}

        data: [DONE]
      SSE

      stub_request(:post, "http://localhost:11500/v1/chat/completions")
        .to_return(status: 200, body: sse_body, headers: { "Content-Type" => "text/event-stream" })

      result = described_class.call(untrusted_text: untrusted_text, metadata: {})

      expect(result[:success]).to be false
      expect(result[:error]).to include("Output guardrail flagged response")
    end

    # rubocop:disable-next RSpec/ExampleLength
    it "succeeds with Gemini provider mapping system rules without sending unsupported system role" do
      url = %r{generativelanguage\.googleapis\.com/.*/models/gemini-3\.7-flash:streamGenerateContent}
      gemini_stub = stub_request(:post, url)
                    .with do |req|
                      body = JSON.parse(req.body)
                      has_system_in_instruction = body.dig("systemInstruction", "parts")&.any? { |p| p["text"].include?("helpful assistant") }
                      has_system_in_contents = body["contents"].any? { |c| c["parts"].any? { |p| p["text"].include?("helpful assistant") } }

                      body["contents"].none? { |c| c["role"] == "system" } &&
                        (has_system_in_instruction || has_system_in_contents)
                    end
                    .to_return(status: 200, body: gemini_sse, headers: { "Content-Type" => "text/event-stream" })

      result = described_class.call(
        untrusted_text: untrusted_text,
        system_rules: "You are a helpful assistant.",
        metadata: {},
        model: gemini_model
      )

      expect(result[:success]).to be true
      expect(result[:output]).to eq("Screening answer text")
      expect(gemini_stub).to have_been_requested
    end
  end
end
