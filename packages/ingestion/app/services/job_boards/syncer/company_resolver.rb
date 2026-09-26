# frozen_string_literal: true

# Resolves (or creates) the Company for a mapped JobPosting and marks it
# ignored if that company has ingestion disabled -- split out of
# JobBoards::Syncer to keep the sync-flow class itself under
# Metrics/ClassLength.
class JobBoards::Syncer::CompanyResolver
  def self.call(job_posting)
    new(job_posting).call
  end

  def initialize(job_posting)
    @job_posting = job_posting
  end

  def call
    return if @job_posting.company_name.blank?

    company = find_or_create_company
    @job_posting.company_id = company.id
    @job_posting.ignore if @job_posting.may_ignore? && !company.ingestion_enabled?
  end

  private

  # New companies matching the big-tech blocklist start with ingestion
  # disabled, so every future posting from them auto-ignores via the
  # ingestion_enabled? check above -- no separate blocklist check needed
  # here or at any other call site.
  def find_or_create_company
    name = @job_posting.company_name
    slug = name.parameterize
    Company.find_by("LOWER(name) = ? OR slug = ?", name.downcase, slug) ||
      create_company(name, slug)
  end

  def create_company(name, slug)
    Company.create!(name: name, slug: slug) do |c|
      c.ingestion_enabled = false if c.big_tech?
    end
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    Company.find_by("LOWER(name) = ? OR slug = ?", name.downcase, slug) || raise
  end
end
