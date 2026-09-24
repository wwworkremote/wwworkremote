# frozen_string_literal: true

class DataQuality::Audit
  FIELD_CHECKS = {
    "Company" => { check: lambda {
      JobPosting.where(company_id: nil).where(company_name: [nil, ""]).count
    }, action: "Assign a canonical company", unlocks: "company history and reliable search" },
    "Company candidate" => { check: lambda {
      DataQuality::CompanyReconciler.candidates(limit: 10_000).length
    }, action: "Approve exact company matches", unlocks: "company history and reliable search" },
    "Application URL" => { check: lambda {
      JobPosting.where(target_url: [nil, ""]).count
    }, action: "Find or verify the employer apply URL", unlocks: "the application workflow" },
    "Description" => { check: lambda {
      JobPosting.where(body: [nil, ""]).count
    }, action: "Run content enrichment", unlocks: "matching and review" },
    "Source" => { check: lambda {
      JobPosting.where(source_id: nil).count
    }, action: "Attach provenance or source", unlocks: "freshness and ingestion accountability" },
    "Signature" => { check: lambda {
      JobPosting.where(signature: [nil, ""]).count
    }, action: "Generate or repair the deduplication key", unlocks: "safe deduplication" },
    "Location" => { check: lambda {
      JobPosting.where(location: [nil, ""]).count
    }, action: "Normalize the job location", unlocks: "remote and geographic filtering" },
    "Published date" => { check: lambda {
      JobPosting.where(published_at: nil).count
    }, action: "Recover publication timing", unlocks: "recency and stale-posting decisions" },
    "Duplicate signature" => { check: lambda {
      duplicate_signature_count
    }, action: "Review and merge duplicate postings", unlocks: "trustworthy counts and triage" }
  }.freeze

  def self.call
    FIELD_CHECKS.map { |field, metadata|
      { field: field, missing: metadata[:check].call, priority: priority(field), action: metadata[:action],
        unlocks: metadata[:unlocks] }
    }
                .select { |finding| finding[:missing].positive? }
                .sort_by { |finding| [-finding[:priority], -finding[:missing]] }
  end

  def self.priority(field)
    { "Company" => 5, "Application URL" => 5, "Description" => 4, "Source" => 4,
      "Location" => 2, "Published date" => 1, "Signature" => 5, "Duplicate signature" => 5, "Company candidate" => 5 }.fetch(field)
  end
  private_class_method :priority

  def self.duplicate_signature_count
    JobPosting.where.not(signature: [nil, ""]).group(:signature).count.values.sum { |count| [count - 1, 0].max }
  end
  private_class_method :duplicate_signature_count
end
