# frozen_string_literal: true

class DataQuality::CompanyReconciler
  def self.candidates(limit: 500)
    companies = Company.where.not(name: [nil, ""]).to_a
    by_name = companies.group_by { |company| normalize(company.name) }

    JobPosting.where(company_id: nil).where.not(company_name: [nil, ""]).limit(limit).filter_map do |posting|
      matches = by_name[normalize(posting.company_name)] || []
      next unless matches.one?

      { posting_id: posting.id, company_name: posting.company_name, company_id: matches.first.id,
        company: matches.first.name }
    end
  end

  def self.normalize(value)
    value.to_s.downcase.gsub(/[^a-z0-9]+/, "").presence
  end
  private_class_method :normalize

  def self.apply!
    candidates = candidates(limit: 10_000)
    JobPosting.transaction {
      candidates.each { |candidate|
        JobPosting.find(candidate[:posting_id]).update!(company_id: candidate[:company_id])
      }
    }
    candidates.length
  end
end
