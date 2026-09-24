# frozen_string_literal: true

# Deterministic application workflow state. This service does not call an
# LLM, fill forms, or submit applications; it tells an operator/runner what
# is safe and what still requires evidence or human confirmation.
class Applications::CyclePlan
  STEPS = %w[capture reconcile prepare rehearse confirm_applied follow_up interview_prep].freeze

  def self.call(user_job_posting)
    new(user_job_posting).call
  end

  def initialize(user_job_posting)
    @application = user_job_posting
    @posting = user_job_posting.job_posting
  end

  def call
    completed = {
      "capture" => @posting.target_url.present?,
      "reconcile" => @posting.company.present? && @posting.body.present?,
      "prepare" => @application.cover_letter.present? || @application.resume_persona_id.present?,
      "rehearse" => @application.guided_sessions.completed.exists?,
      "confirm_applied" => @application.status.in?(%w[applied interview offered]) && @application.applied_at.present?,
      "follow_up" => @application.follow_up_at.present?,
      "interview_prep" => @application.status != "interview" || @application.interview_prep_pack.present?
    }

    next_step = STEPS.find { |step| !completed.fetch(step) }
    {
      application_id: @application.id,
      job_posting_id: @posting.id,
      status: @application.status,
      completed: completed,
      next_step: next_step,
      ready_for_human_confirmation: next_step == "confirm_applied",
      safe_to_advance_automatically: next_step.in?(%w[capture reconcile prepare rehearse]),
      blocked_reason: next_step == "confirm_applied" ? "External submission evidence and human confirmation required" : nil,
      provider_strategy: Applications::ProviderStrategy.for(provider).to_h,
      interview_prep: {
        required: @application.status == "interview",
        ready: @application.interview_prep_pack.present?,
        action: @application.status == "interview" && @application.interview_prep_pack.blank? ? "generate_interview_prep" : nil
      },
      receipts: receipts
    }
  end

  def provider
    @posting.data["provider"].presence || @posting.source&.name.presence || detected_provider
  end

  def detected_provider
    detected = JobFetchers::ProviderDetector.call(@posting.target_url)
    detected == "generic" ? "unknown" : detected
  end

  def receipts
    receipts = [{ "kind" => "posting", "id" => @posting.id, "url" => "/job_postings/#{@posting.id}" },
                { "kind" => "application", "id" => @application.id,
                  "url" => "/user_job_postings/#{@application.id}" },
                { "kind" => "history", "id" => @application.id, "url" => "/job_postings/#{@posting.id}#activity" }]
    receipt = PipelineStep.where(user_id: @application.user_id, job_posting_id: @posting.id, status: "apply")
                          .where.not(link: [nil, ""])
                          .order(created_at: :desc).first
    receipts << { "kind" => "external_submission", "id" => receipt.id, "url" => receipt.link } if receipt
    receipts
  end
end
