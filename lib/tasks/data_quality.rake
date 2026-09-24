# frozen_string_literal: true

namespace :data_quality do
  desc "Print ranked missing-data findings as JSON"
  task audit: :environment do
    puts JSON.pretty_generate(DataQuality::Audit.call)
  end

  desc "Print unambiguous company reconciliation candidates without changing data"
  task company_candidates: :environment do
    puts JSON.pretty_generate(DataQuality::CompanyReconciler.candidates)
  end

  desc "Audit supervised application sessions that reached Applied"
  task application_cycle: :environment do
    puts JSON.pretty_generate(GuidedSessions::CompletionAudit.call)
  end
end
