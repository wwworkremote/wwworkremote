# frozen_string_literal: true

# == Schema Information
#
# Table name: resume_refreshes
#
#  id              :bigint           not null, primary key
#  approved_at     :datetime
#  plan            :jsonb            not null
#  provider        :string           not null
#  rejected_at     :datetime
#  resolution_note :text
#  status          :string           default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_resume_refreshes_on_user_id             (user_id)
#  index_resume_refreshes_on_user_id_and_status  (user_id,status)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :resume_refresh do
    user
    provider { "file_json" }
    plan {
      { "positions" => { "added" => [], "changed" => [], "removed" => [] },
        "archetypes" => { "added" => [], "changed" => [], "removed" => [] } }
    }
  end
end
