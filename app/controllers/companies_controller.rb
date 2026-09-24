# frozen_string_literal: true

class CompaniesController < ApplicationController
  # This index deliberately keeps query, filter, and sort semantics together
  # so every control preserves the same result set.
  # rubocop:disable-next-line Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
  def index
    @query = params[:q].to_s.strip.presence
    @sort = %w[name postings].include?(params[:sort]) ? params[:sort] : "postings"
    @filter = %w[all active paused cooldown].include?(params[:filter]) ? params[:filter] : "all"
    scope = Company.select("companies.*, count(job_postings.id) as job_postings_count")
                   .left_joins(:job_postings)
                   .group("companies.id")
    if @query
      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
      scope = scope.where("companies.name ILIKE :pattern", pattern: pattern)
    end
    scope = scope.where(ingestion_enabled: true) if @filter == "active"
    scope = scope.where(ingestion_enabled: false) if @filter == "paused"
    scope = scope.where("companies.last_declined_at > ?", 6.months.ago) if @filter == "cooldown"
    @companies = scope.order(@sort == "name" ? { name: :asc } : { job_postings_count: :desc, name: :asc })
                      .page(params[:page]).per(24)
  end

  def show
    @company = Company.includes(:job_postings).find(params.expect(:id))
    load_harness_summary
  end

  private

  # Read-only harness legibility (ADR 010 / TASK-125): how many of this
  # company's applications went through the harness, and each posting's state.
  def load_harness_summary
    tracked = tracked_applications
    @harness_by_posting = tracked.index_by(&:job_posting_id)
    @harness_processed_count = tracked.processed_through_harness.count
    @harness_recorded_sessions = GuidedSession.completed.where(user_job_posting_id: tracked.ids).count
  end

  def tracked_applications
    current_user.user_job_postings.where(job_posting_id: @company.job_postings.map(&:id))
  end
end
