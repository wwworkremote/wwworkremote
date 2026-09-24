# frozen_string_literal: true

class HomeController < ApplicationController
  PRIORITY_INBOX_STATUSES = ["none", nil].freeze

  def index
    assign_top_matches
    assign_priority_inbox
    assign_idle_followups
    assign_funnel_health
    assign_next_action
    @upcoming_interviews = InterviewSession.where(user: current_user).includes(:job_posting).where(scheduled_at: Time.current..).order(scheduled_at: :asc).limit(6)
    @active_applications_count = current_user.user_job_postings.where(status: %w[applied interview]).count
    @source_stats = top_source_stats
    @daily_progress = daily_progress
  end

  private

  def assign_idle_followups
    @idle_followups = current_user.user_job_postings.idle.includes(:job_posting).limit(6)
  end

  def daily_progress
    steps = PipelineStep.where(user: current_user, created_at: Time.current.beginning_of_day..)
    completed = steps.where(status: %w[favorited applied interview]).count +
                InterviewSession.where(user: current_user,
                                       updated_at: Time.current.beginning_of_day..).where.not(outcome: "pending").count
    next_action = if @idle_followups.any?
                    ["Follow up on an active application", user_job_postings_path(status: "idle", sort: "oldest")]
                  elsif @priority_inbox.any?
                    ["Review a high-match job", job_posting_triage_path]
                  else
                    ["Find a strong next opportunity", job_postings_path]
                  end
    { completed: completed, target: 3, next: next_action.first, path: next_action.last }
  end

  # TASK-81: the scrapers are the healthiest part of this app -- ingestion
  # health is already visible everywhere. What's never surfaced is the
  # narrowest point in the funnel: how long since Mike last actually
  # applied to anything, and how many tracked postings never got triaged
  # past "none" at all. Deliberately 3 numbers, not a chart -- the failure
  # mode this task calls out by name is building more platform instead of
  # applying.
  def assign_funnel_health
    untriaged = current_user.user_job_postings.where(status: PRIORITY_INBOX_STATUSES)

    @untriaged_count = untriaged.count
    @oldest_untriaged_at = untriaged.minimum(:created_at)
    @last_application_at = last_application_at
  end

  # Two signals, not one: the live UI logs a PipelineStep on every apply
  # event, but the import scripts (bin/import_indeed_applications,
  # bin/import_greenhouse_applications) write UserJobPosting#applied_at
  # directly and never log one. Whichever is more recent is the honest
  # answer.
  def last_application_at
    [
      PipelineStep.where(user: current_user, status: "applied").maximum(:created_at),
      current_user.user_job_postings.maximum(:applied_at)
    ].compact.max
  end

  def assign_top_matches
    return if current_user.career_profile&.embedding.blank?

    @top_matches = Resume::SemanticMatchFinder.call(current_user.career_profile, limit: 6)
  end

  def assign_priority_inbox
    @priority_inbox = current_user.user_job_postings
                                  .includes(:job_posting)
                                  .where(priority_flag: true, status: PRIORITY_INBOX_STATUSES)
                                  .limit(6)
  end

  # The priority order is the product decision; keeping it explicit makes the
  # command center's recommendation auditable.
  # rubocop:disable-next-line Metrics/AbcSize, Metrics/MethodLength
  def assign_next_action
    if @priority_inbox.first
      job = @priority_inbox.first.job_posting
      @next_action = { job: job, label: "Review match", reason: "High match waiting for your decision" }
    elsif @idle_followups.first
      job = @idle_followups.first.job_posting
      @next_action = { job: job, label: "Follow up", reason: "This application has been idle" }
    elsif @top_matches&.first
      @next_action = { job: @top_matches.first, label: "Review match", reason: "Strong alignment with your profile" }
    else
      @next_action = { path: job_postings_path, label: "Browse jobs", reason: "Find your next opportunity" }
    end
  end

  # Efficiently aggregate stats by Origin name -- one cohesive query
  # chain, splitting it further would obscure it, not simplify it.
  # rubocop:disable-next Metrics/MethodLength
  def top_source_stats
    Origin.joins(sources: :job_postings)
          .group("origins.name")
          .count
          .map { |name, count| { name: name, count: count } }
          .sort_by { |s| -s[:count] }
          .first(5)
  end
end
