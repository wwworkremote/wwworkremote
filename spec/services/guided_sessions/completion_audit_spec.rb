# frozen_string_literal: true

RSpec.describe GuidedSessions::CompletionAudit do
  it "does not count an active applied session as a completed cycle" do
    posting = create(:job_posting)
    user_job = create(:user_job_posting, job_posting: posting, status: "applied")
    create(:guided_session, purpose: "application_execution", user_job_posting: user_job, status: "active")

    result = described_class.call

    expect(result[:linked_sessions]).to eq(1)
    expect(result[:completed_applied_sessions]).to eq(0)
    expect(result[:incomplete].first).to include(session_status: "active", posting_status: "applied")
  end
end
