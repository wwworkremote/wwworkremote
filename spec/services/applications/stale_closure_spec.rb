# frozen_string_literal: true

RSpec.describe Applications::StaleClosure do
  let(:as_of) { Time.zone.parse("2026-09-10 12:00:00") }

  it "closes quiet active applications, including interviews, and preserves the stage" do
    old_interview = create(:user_job_posting, status: "interview", created_at: as_of - 20.days,
                                              updated_at: as_of - 20.days)
    create(:pipeline_step, user: old_interview.user, job_posting: old_interview.job_posting,
                           status: "interview", created_at: as_of - 20.days)
    recent = create(:user_job_posting, status: "interview", created_at: as_of - 20.days, updated_at: as_of - 20.days)
    create(:pipeline_step, user: recent.user, job_posting: recent.job_posting,
                           status: "interview", created_at: as_of - 2.days)

    result = described_class.call(as_of: as_of)

    expect(result[:application_ids]).to include(old_interview.id)
    expect(old_interview.reload).to have_attributes(status: "interview", outcome: "closed",
                                                    outcome_source: "stale_cleanup",
                                                    outcome_reason: "No response after 15 days")
    expect(old_interview.outcome_at).to be_within(1.second).of(as_of)
    expect(recent.reload.outcome).to be_nil
    expect(described_class.call(as_of: as_of, dry_run: true)[:count]).to eq(0)
  end

  it "supports a dry run without changing records" do
    application = create(:user_job_posting, status: "applied", created_at: as_of - 20.days, updated_at: as_of - 20.days)

    result = described_class.call(as_of: as_of, dry_run: true)

    expect(result).to include(count: 1, dry_run: true)
    expect(application.reload.outcome).to be_nil
  end

  it "does not reselect an already closed outcome" do
    create(:user_job_posting, status: "interview", outcome: "closed", created_at: as_of - 20.days,
                              updated_at: as_of - 20.days)

    expect(described_class.call(as_of: as_of, dry_run: true)[:count]).to eq(0)
  end
end
