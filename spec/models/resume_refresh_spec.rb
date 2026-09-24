# frozen_string_literal: true

require "rails_helper"

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
RSpec.describe ResumeRefresh do
  it "records an approval decision with a timestamp" do
    refresh = create(:resume_refresh)
    refresh.approve!(note: "Reviewed additions")
    expect(refresh.reload).to have_attributes(status: "approved", resolution_note: "Reviewed additions")
    expect(refresh.approved_at).to be_present
  end

  it "records rejection without deleting the plan" do
    refresh = create(:resume_refresh)
    refresh.reject!(note: "Keep curated profile")
    expect(refresh.reload).to have_attributes(status: "rejected", resolution_note: "Keep curated profile")
    expect(refresh.plan).to be_present
  end
end
