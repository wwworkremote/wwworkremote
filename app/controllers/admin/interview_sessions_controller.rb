# frozen_string_literal: true

class Admin::InterviewSessionsController < ApplicationController
  def create
    @job_posting = JobPosting.find(params.expect(:job_posting_id))
    build_session
    @session.save ? redirect_on_session_saved : redirect_on_session_failed
  end

  def update
    @session = InterviewSession.find(params.expect(:id))
    @session.update!(session_params)
    redirect_to job_posting_path(@session.job_posting), notice: "Interview outcome recorded."
  end

  def seed
    @job_posting = JobPosting.find(params.expect(:job_posting_id))
    seed_interview_process
    redirect_to @job_posting, notice: "Seeded interview process (#{selected_template.to_s.humanize})."
  end

  private

  def seed_interview_process
    ujp = current_user.user_job_postings.find_or_create_by!(job_posting: @job_posting)
    InterviewProcess.seed_default(ujp, template: selected_template)
  end

  def selected_template
    params[:template].presence || :standard_senior
  end

  def build_session
    @session = @job_posting.interview_sessions.build(session_params)
    @session.user = current_user
    @session.position ||= next_position
  end

  def next_position
    max_position = @job_posting.interview_sessions.where(user: current_user).maximum(:position) || 0
    max_position + 1
  end

  def redirect_on_session_saved
    redirect_to @job_posting, notice: "🚀 Interview session initialized in the Laboratory."
  end

  def redirect_on_session_failed
    redirect_to @job_posting, alert: "Failed to initialize session: #{@session.errors.full_messages.join(', ')}"
  end

  def session_params
    params.permit(:session_type, :scheduled_at, :notes, :vibe, :feedback, :outcome, :interviewers, :position)
  end
end
