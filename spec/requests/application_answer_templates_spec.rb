# frozen_string_literal: true

RSpec.describe "Application answer templates" do
  let(:user) { User.find_or_create_by!(email: "mike@just3ws.com") { |u| u.name = "mike"; u.password = "password" } }

  before do
    allow(Resume::PersonaContext).to receive(:personas).and_return([])
  end

  it "normalizes a newly authored prompt so coverage can resolve it" do
    post application_answer_templates_path, params: {
      application_answer_template: {
        question_kind: "eligibility", normalized_prompt: "", prompt: "Are you legally authorized to work?",
        answer: "Yes", source: "manual", enabled: true
      }
    }

    expect(response).to redirect_to(application_answer_templates_path)
    expect(user.application_answer_templates.last.normalized_prompt).to eq("are you legally authorized to work")
  end

  it "lets the owner edit and disable a canned answer" do
    template = user.application_answer_templates.create!(question_kind: "contact", normalized_prompt: "phone",
                                                         prompt: "Phone?", answer: "555-0100", source: "manual")

    patch application_answer_template_path(template), params: {
      application_answer_template: { question_kind: "contact", prompt: "Best phone number?", answer: "555-0101", enabled: "0" }
    }

    expect(response).to redirect_to(application_answer_templates_path)
    expect(template.reload).to have_attributes(prompt: "Best phone number?", answer: "555-0101",
                                               normalized_prompt: "best phone number", enabled: false)
  end
end
