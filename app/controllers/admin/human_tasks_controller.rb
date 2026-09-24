# frozen_string_literal: true

# The task inbox: every open HumanTask an automated evaluator (a BPMN
# "Service Task", e.g. Pipeline::PersonaRecommender) has proposed and is
# waiting on a human to approve, edit, or reject. This is the actual
# "awaiting human" surface TASK-97 asked for -- PR-review style, showing the
# proposed content itself, not just a state name.
class Admin::HumanTasksController < Admin::ApplicationController
  def index
    @human_tasks = HumanTask.open.includes(:job_posting).order(created_at: :asc)
    @guided_sessions = GuidedSession.where(session_token: @human_tasks.filter_map { |task|
      task.payload["guided_session_token"]
    }).index_by(&:session_token)
  end

  def approve
    task = HumanTask.find(params.expect(:id))
    if task.kind == "submit_approval" && (!valid_receipt_url?(params[:receipt_url]) || params[:agreement_confirmed] != "1")
      return redirect_to admin_human_tasks_path,
                         alert: "Confirm the employer agreement and add its receipt URL before marking Applied."
    end
    apply_proposal(task) if task.kind == "persona_review"
    submit_proposal(task, params[:receipt_url]) if task.kind == "submit_approval"
    task.approve!
    redirect_to admin_human_tasks_path,
                notice: task.kind == "submit_approval" ? "Application marked applied with approval receipt." : "Approved and applied."
  end

  def reject
    task = HumanTask.find(params.expect(:id))
    task.update!(resolution_note: params[:resolution_note])
    task.reject!
    redirect_to admin_human_tasks_path, notice: "Rejected."
  end

  private

  # Mirrors Api::V0::ApplicationContextsController#update -- same persona
  # -setting effect, triggered from the inbox instead of the extension panel.
  def apply_proposal(task)
    persona_id = task.payload["persona_id"]
    return if persona_id.blank? || persona_id == "none"

    context = Resume::PersonaContext.call(persona_id)
    user_job_posting_for(task).update!(resume_persona_id: context.fetch("id"), resume_persona_snapshot: context)
  end

  def user_job_posting_for(task)
    task.user.user_job_postings.find_or_create_by!(job_posting: task.job_posting)
  end

  def submit_proposal(task, receipt_url)
    application = user_job_posting_for(task)
    return if application.status == "applied"

    approved_at = Time.current
    task.update!(payload: task.payload.merge("agreement_acknowledged_at" => approved_at.utc.iso8601,
                                             "receipt_url" => receipt_url,
                                             "approval_confirmed_at" => approved_at.utc.iso8601))
    application.record_status_event!("apply", link: receipt_url)
    application.update!(applied_at: approved_at, follow_up_at: application.follow_up_at || 7.days.from_now)
  end

  def valid_receipt_url?(value)
    uri = URI.parse(value.to_s)
    %w[http https].include?(uri.scheme) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
