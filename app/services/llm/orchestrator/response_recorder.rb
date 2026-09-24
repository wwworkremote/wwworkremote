# frozen_string_literal: true

# Persists the assistant's LLMMessage (with token usage) and records
# OTel span usage/cost attributes -- split out to keep the orchestrator
# itself under Metrics/ClassLength.
class LLM::Orchestrator::ResponseRecorder
  def self.call(chat, model, message, span)
    new(chat, model, message, span).call
  end

  def initialize(chat, model, message, span)
    @chat = chat
    @model = model
    @message = message
    @span = span
  end

  def call
    full_output = @message.content.to_s
    persist_assistant_message(full_output) if full_output.present?
    record_usage_attributes
    @span.add_event("received_llm_response", attributes: {})
    full_output
  end

  private

  # One cohesive create! call -- splitting it further would obscure it,
  # not simplify it.
  # rubocop:disable-next Metrics/MethodLength
  def persist_assistant_message(full_output)
    @chat.llm_messages.create!(
      role: "assistant",
      content: full_output,
      model_id: @model.id,
      input_tokens: input_tokens,
      output_tokens: output_tokens,
      cached_tokens: cached_tokens
    )
  end

  def record_usage_attributes
    set_attribute("app.llm.input_tokens", input_tokens)
    set_attribute("app.llm.output_tokens", output_tokens)
    set_attribute("app.llm.cached_tokens", cached_tokens)
    set_attribute("app.llm.cost_usd", cost)
  end

  def input_tokens
    @message.respond_to?(:tokens) && @message.tokens ? @message.tokens.input : @message.try(:input_tokens)
  end

  def output_tokens
    @message.respond_to?(:tokens) && @message.tokens ? @message.tokens.output : @message.try(:output_tokens)
  end

  def cached_tokens
    @message.respond_to?(:tokens) && @message.tokens ? @message.tokens.cache_read : @message.try(:cached_tokens)
  end

  def cost
    return nil unless @message.respond_to?(:cost)

    cost_obj = @message.method(:cost).arity.zero? ? @message.cost : @message.cost(model: @model.model_id)
    cost_obj&.total
  rescue StandardError
    nil
  end

  def set_attribute(key, value)
    @span.set_attribute(key, value) if value
  end
end
