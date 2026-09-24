# frozen_string_literal: true

# == Schema Information
#
# Table name: guided_sessions
#
#  id                  :bigint           not null, primary key
#  phase               :string           default("intake"), not null
#  playback_position   :integer          default(0), not null
#  provider            :string           not null
#  purpose             :string           default("application_execution"), not null
#  session_token       :string           not null
#  source_url          :string           not null
#  started_at          :datetime         not null
#  status              :string           default("active"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  scenario_id         :bigint
#  user_job_posting_id :bigint
#
# Indexes
#
#  index_guided_sessions_on_scenario_id          (scenario_id)
#  index_guided_sessions_on_session_token        (session_token) UNIQUE
#  index_guided_sessions_on_user_job_posting_id  (user_job_posting_id)
#
# Foreign Keys
#
#  fk_rails_...  (scenario_id => scenarios.id)
#  fk_rails_...  (user_job_posting_id => user_job_postings.id)
#
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
