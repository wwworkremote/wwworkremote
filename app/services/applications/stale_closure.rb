# frozen_string_literal: true

# Closes active applications that have gone quiet for the configured period.
# The pipeline stage is intentionally preserved: `outcome` records the
# employer signal, while status records the candidate's stage history.
class Applications::StaleClosure
  DEFAULT_AGE = 15.days
  ACTIVE_STATUSES = UserJobPosting::ACTIVE_STATUSES

  def self.call(as_of: Time.current, age: DEFAULT_AGE, dry_run: false)
    new(as_of: as_of, age: age, dry_run: dry_run).call
  end

  def initialize(as_of:, age:, dry_run:)
    @as_of = as_of
    @cutoff = as_of - age
    @dry_run = dry_run
  end

  def call
    candidates = UserJobPosting.where(status: ACTIVE_STATUSES)
                               .where("outcome IS NULL OR outcome NOT IN (?)", UserJobPosting::TERMINAL_OUTCOMES)
                               .includes(:job_posting)
                               .select { |application| application.last_pipeline_activity_at < @cutoff }

    candidates.each { |application| close(application) } unless @dry_run
    { count: candidates.length, application_ids: candidates.map(&:id), cutoff: @cutoff, dry_run: @dry_run }
  end

  private

  def close(application)
    application.update!(outcome: "closed", outcome_at: @as_of, outcome_source: "stale_cleanup",
                        outcome_reason: "No response after 15 days")
  end
end
