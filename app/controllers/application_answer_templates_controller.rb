# frozen_string_literal: true

class ApplicationAnswerTemplatesController < ApplicationController
  def index
    @templates = current_user.application_answer_templates.order(updated_at: :desc)
    @personas = Resume::PersonaContext.personas
    covered = @templates.where(enabled: true).pluck(:normalized_prompt)
    @pending_questions = QuestionOccurrence.where(user_id: current_user.id)
                                           .where.not(normalized_prompt: covered)
                                           .order(observed_at: :desc).limit(50)
  rescue StandardError => e
    Rails.logger.warn("[AnswerLibrary] persona list unavailable: #{e.class}: #{e.message}")
    @personas = []
  end

  def create
    current_user.application_answer_templates.create!(template_params)
    redirect_to application_answer_templates_path, notice: "Canned answer saved."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to application_answer_templates_path, alert: e.message
  end

  def update
    template = current_user.application_answer_templates.find(params.expect(:id))
    template.update!(template_params)
    redirect_to application_answer_templates_path, notice: "Canned answer updated."
  end

  private

  def template_params
    attrs = params.expect(application_answer_template: %i[persona_id question_kind normalized_prompt prompt answer
                                                          source enabled])
    attrs[:normalized_prompt] = ApplicationFieldQuestionClassifier.normalize(attrs[:prompt])
    attrs
  end
end
