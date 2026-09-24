# frozen_string_literal: true

FactoryBot.define do
  factory :guided_session do
    source_url { "https://jobs.example.com/role" }
    provider { "example" }
    purpose { "application_execution" }
    phase { "intake" }
    status { "active" }
    started_at { Time.current }
  end
end
