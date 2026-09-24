# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::HumanTasks" do
  let(:user) { create(:user) }
  let(:job_posting) { create(:job_posting) }
  let(:persona_source) do
    {
      "archetypes" => {
        "founding_staff_fullstack" => {
          "short_label" => "Founding Staff", "title" => "Founding Staff Engineer",
          "target_tier" => "early-stage", "summary" => "Summary", "core_skills" => [],
          "featured_positions" => [], "additional_experience" => [], "selected_projects" => []
        }
      }, "positions" => {}
    }
  end

  before do
    allow(Resume::Source).to receive(:new).and_return(instance_double(Resume::Source, to_h: persona_source))
  end

  describe "GET /admin/human_tasks" do
    it "lists only open tasks" do
      open_task = create(:human_task, job_posting: job_posting, user: user)
      create(:human_task, job_posting: job_posting, user: user, status: "approved")

      get admin_human_tasks_path

      expect(response).to have_http_status(:ok)
      expect(assigns(:human_tasks)).to contain_exactly(open_task)
    end

    it "orders open tasks oldest first" do
      newer = create(:human_task, job_posting: job_posting, user: user, created_at: 1.hour.ago)
      older = create(:human_task, job_posting: job_posting, user: user, created_at: 2.days.ago)

      get admin_human_tasks_path

      expect(assigns(:human_tasks)).to eq([older, newer])
    end

    it "loads the guided session referenced by a submission approval" do
      session = GuidedSession.create!(source_url: "https://jobs.example.com/role", provider: "example")
      task = create(:human_task, job_posting: job_posting, user: user, kind: "submit_approval",
                                 payload: { "guided_session_token" => session.session_token })

      get admin_human_tasks_path

      expect(assigns(:guided_sessions)).to include(session.session_token => session)
      expect(response.body).to include(%(id="approve-human-task-#{task.id}"))
      expect(response.body).to include("Approve and mark Applied")
      expect(response.body).to include("name=\"agreement_confirmed\"")
    end
  end

  describe "POST /admin/human_tasks/:id/approve" do
    it "applies the proposed persona and resolves the task" do
      task = create(:human_task, job_posting: job_posting, user: user,
                                 payload: { "persona_id" => "founding_staff_fullstack" })

      post approve_admin_human_task_path(task)

      expect(response).to redirect_to(admin_human_tasks_path)
      expect(task.reload).to be_approved
      expect(user.user_job_postings.find_by(job_posting: job_posting).resume_persona_id)
        .to eq("founding_staff_fullstack")
    end

    it "does not apply anything when the proposal was 'none'" do
      task = create(:human_task, job_posting: job_posting, user: user, payload: { "persona_id" => "none" })

      post approve_admin_human_task_path(task)

      expect(task.reload).to be_approved
      expect(user.user_job_postings.find_by(job_posting: job_posting)).to be_nil
    end

    it "marks the linked application applied only after human approval" do
      application = create(:user_job_posting, user: user, job_posting: job_posting, status: "favorited")
      task = create(:human_task, job_posting: job_posting, user: user, kind: "submit_approval",
                                 payload: { "guided_session_token" => "receipt-token" })

      post approve_admin_human_task_path(task), params: { receipt_url: "https://employer.example/confirmation/123", agreement_confirmed: "1" }

      expect(task.reload).to be_approved
      expect(application.reload.status).to eq("applied")
      expect(application.applied_at).to be_present
      expect(application.follow_up_at).to be_within(2.seconds).of(7.days.from_now)
      expect(PipelineStep.order(:id).last.link).to eq("https://employer.example/confirmation/123")
      expect(task.reload.payload["agreement_acknowledged_at"]).to be_present
      expect(task.reload.payload["approval_confirmed_at"]).to be_present
    end

    it "preserves a manually scheduled follow-up" do
      follow_up = 3.days.from_now
      application = create(:user_job_posting, user: user, job_posting: job_posting, status: "favorited",
                                              follow_up_at: follow_up)
      task = create(:human_task, job_posting: job_posting, user: user, kind: "submit_approval")

      post approve_admin_human_task_path(task), params: { receipt_url: "https://employer.example/confirmation/456", agreement_confirmed: "1" }

      expect(application.reload.follow_up_at).to be_within(2.seconds).of(follow_up)
    end

    it "refuses Applied without an external receipt URL" do
      task = create(:human_task, job_posting: job_posting, user: user, kind: "submit_approval")

      post approve_admin_human_task_path(task)

      expect(task.reload).to be_pending
    end

    it "refuses Applied without agreement acknowledgement" do
      task = create(:human_task, job_posting: job_posting, user: user, kind: "submit_approval")

      post approve_admin_human_task_path(task), params: { receipt_url: "https://employer.example/confirmation/789" }

      expect(task.reload).to be_pending
    end
  end

  describe "POST /admin/human_tasks/:id/reject" do
    it "resolves the task without touching the pipeline" do
      task = create(:human_task, job_posting: job_posting, user: user)

      post reject_admin_human_task_path(task), params: { resolution_note: "Wrong persona for this role." }

      expect(task.reload).to be_rejected
      expect(task.resolution_note).to eq("Wrong persona for this role.")
    end
  end

  it "carries a receipt-backed application through interview preparation" do
    application = create(:user_job_posting, user: user, job_posting: job_posting, status: "favorited")
    session = create(:guided_session, user_job_posting: application, status: "completed")
    task = create(:human_task, job_posting: job_posting, user: user, kind: "submit_approval",
                               payload: { "guided_session_token" => session.session_token })

    post approve_admin_human_task_path(task), params: {
      receipt_url: "https://employer.example/confirmation/e2e", agreement_confirmed: "1"
    }
    expect(application.reload).to have_attributes(status: "applied", applied_at: be_present, follow_up_at: be_present)

    allow_any_instance_of(UserJobPostingsController).to receive(:current_user).and_return(user)
    post user_job_postings_path, params: { job_posting_id: job_posting.id, status: "interview" }
    expect(application.reload.status).to eq("interview")

    allow(LLM::InterviewPrepGenerator).to receive(:call) do |_, posting, **|
      expect(posting).to eq(job_posting)
      application.update!(interview_prep_pack: "# Prep pack", interview_prep_pack_generated_at: Time.current)
      { success: true }
    end
    post generate_interview_prep_user_job_postings_path, params: { job_posting_id: job_posting.id }

    expect(application.reload.interview_prep_pack).to eq("# Prep pack")
    expect(Applications::CyclePlan.call(application)[:interview_prep]).to include(required: true, ready: true,
                                                                                  action: nil)
  end
end
