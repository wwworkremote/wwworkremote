# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::InterviewSessions" do
  let(:job_posting) { create(:job_posting) }

  describe "POST /admin/job_postings/:job_posting_id/interview_sessions" do
    it "creates the session for the current user and redirects with a notice" do
      post admin_job_posting_interview_sessions_path(job_posting),
           params: { session_type: "Technical", scheduled_at: 1.day.from_now }

      session = job_posting.interview_sessions.last
      expect(session).to be_present
      expect(session.user.email).to eq("mike@just3ws.com")
      expect(response).to redirect_to(job_posting)
      expect(flash[:notice]).to eq("🚀 Interview session initialized in the Laboratory.")
    end

    it "auto-assigns sequential position when not specified" do
      post admin_job_posting_interview_sessions_path(job_posting),
           params: { session_type: "Screening", scheduled_at: 1.day.from_now }
      post admin_job_posting_interview_sessions_path(job_posting),
           params: { session_type: "Technical", scheduled_at: 2.days.from_now }

      positions = job_posting.interview_sessions.order(:id).pluck(:position)
      expect(positions).to eq([1, 2])
    end

    it "redirects with an alert listing validation errors when required fields are missing" do
      post admin_job_posting_interview_sessions_path(job_posting), params: { session_type: "" }

      expect(job_posting.interview_sessions.count).to eq(0)
      expect(response).to redirect_to(job_posting)
      expect(flash[:alert]).to include("Failed to initialize session:")
    end
  end

  describe "POST /admin/job_postings/:job_posting_id/interview_sessions/seed" do
    it "seeds default template rounds for the posting and redirects" do
      expect do
        post seed_admin_job_posting_interview_sessions_path(job_posting), params: { template: "compressed" }
      end.to change(job_posting.interview_sessions, :count).by(6)

      expect(response).to redirect_to(job_posting)
      expect(flash[:notice]).to include("Seeded interview process")
      expect(job_posting.interview_sessions.ordered.first.notes).to eq("Recruiter screen")
    end
  end

  describe "PATCH /admin/job_postings/:job_posting_id/interview_sessions/:id" do
    it "records an interview outcome" do
      session = job_posting.interview_sessions.create!(user: create(:user), session_type: "Technical",
                                                       scheduled_at: 1.day.from_now)

      patch admin_job_posting_interview_session_path(job_posting, session), params: { outcome: "passed" }

      expect(session.reload.outcome).to eq("passed")
      expect(response).to redirect_to(job_posting)
    end
  end
end
