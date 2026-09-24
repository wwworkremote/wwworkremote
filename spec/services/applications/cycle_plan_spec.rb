# frozen_string_literal: true

RSpec.describe Applications::CyclePlan do
  it "stops at human confirmation instead of claiming an application was submitted" do
    posting = create(:job_posting, body: "A real role", target_url: "https://jobs.example.com/role")
    application = create(:user_job_posting, job_posting: posting, status: "applied", applied_at: Time.current)
    GuidedSession.create!(source_url: posting.target_url, provider: "example", purpose: "application_execution",
                          user_job_posting: application, status: "completed")

    result = described_class.call(application)

    expect(result[:next_step]).to eq("prepare")
    expect(result[:ready_for_human_confirmation]).to be(false)
    expect(result[:safe_to_advance_automatically]).to be(true)
    expect(result[:receipts].pluck("kind")).to include("history")
    expect(result[:provider_strategy]).to include(application_method: "external_site", auto_fill: false)
    expect(result[:interview_prep]).to include(required: false, ready: false, action: nil)
  end

  it "returns the external submission receipt when one was captured" do
    posting = create(:job_posting, body: "A real role", target_url: "https://jobs.example.com/role")
    application = create(:user_job_posting, job_posting: posting, status: "applied", applied_at: Time.current)
    step = create(:pipeline_step, user: application.user, job_posting: posting, status: "apply",
                                  link: "https://employer.example/confirmation/123")

    receipt = described_class.call(application)[:receipts].find { |item| item["kind"] == "external_submission" }

    expect(receipt).to include("id" => step.id, "url" => step.link)
  end

  it "requires evidence before treating Applied as confirmed" do
    posting = create(:job_posting, target_url: "https://jobs.example.com/role")
    application = create(:user_job_posting, job_posting: posting, status: "applied", applied_at: nil)

    result = described_class.call(application)

    expect(result[:completed]["confirm_applied"]).to be(false)
    expect(result[:blocked_reason]).to be_nil
  end

  it "derives the application provider from the canonical URL when metadata is absent" do
    greenhouse = create(:job_posting, body: "A real role", target_url: "https://careers.toasttab.com/jobs?gh_jid=8186228")
    workday = create(:job_posting, body: "A real role", target_url: "https://myhrhome.wd1.myworkdayjobs.com/OneMainCareers/job/role")

    expect(described_class.call(create(:user_job_posting,
                                       job_posting: greenhouse))[:provider_strategy]).to include(label: "Greenhouse")
    expect(described_class.call(create(:user_job_posting,
                                       job_posting: workday))[:provider_strategy]).to include(label: "Workday")
  end

  it "surfaces interview preparation as the next action" do
    posting = create(:job_posting, body: "A real role", target_url: "https://jobs.example.com/role")
    application = create(:user_job_posting, job_posting: posting, status: "interview", cover_letter: "Tailored letter",
                                            applied_at: 3.days.ago, follow_up_at: 2.days.from_now)
    GuidedSession.create!(source_url: posting.target_url, provider: "example", purpose: "application_execution",
                          user_job_posting: application, status: "completed")

    result = described_class.call(application)

    expect(result[:next_step]).to eq("interview_prep")
    expect(result[:interview_prep]).to include(required: true, ready: false, action: "generate_interview_prep")
    expect(result[:safe_to_advance_automatically]).to be(false)
  end
end
