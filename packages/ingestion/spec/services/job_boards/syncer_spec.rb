# frozen_string_literal: true

require "rails_helper"

RSpec.describe JobBoards::Syncer, type: :service do
  let(:service) { described_class.new }
  let(:source) { JobBoards::Source.find_or_create_by!(slug: "remotive", name: "Remotive") }
  let(:query) { JobBoards::Query.find_or_create_by!(source_id: source.id) }
  let(:job_data) do
    {
      id: "123",
      title: "Ruby Developer",
      description: "Cool job",
      url: "https://example.com/job",
      publication_date: "2024-01-01T12:00:00Z",
      company_name: "Acme Corp",
      candidate_required_location: "Worldwide"
    }
  end
  let(:document) do
    JobBoards::Document.create!(
      signature: "remotive-123",
      source_id: source.id,
      job_boards_query_id: query.id,
      document: job_data.to_json
    )
  end

  describe "#call" do
    it "creates a JobPosting from a JobBoards::Document" do
      document # Ensure document exists
      expect {
        service.call
      }.to change(JobPosting, :count).by(1)

      posting = JobPosting.last
      expect(posting.title).to eq("Ruby Developer")
      expect(posting.company_name).to eq("Acme Corp")
      expect(posting.signature).to eq("remotive-123")
    end

    it "is idempotent" do
      document # Ensure document exists
      service.call
      expect {
        service.call
      }.not_to change(JobPosting, :count)
    end

    context "when QualityFilter rejects the posting (e.g. a non-Engineering title)" do
      let(:job_data) do
        {
          id: "456",
          title: "Account Executive",
          description: "Cool sales job",
          url: "https://example.com/job",
          publication_date: "2024-01-01T12:00:00Z",
          company_name: "Acme Corp",
          candidate_required_location: "Worldwide"
        }
      end
      let(:document) do
        JobBoards::Document.create!(
          signature: "remotive-456", source_id: source.id, job_boards_query_id: query.id, document: job_data.to_json
        )
      end

      before { ActiveJob::Base.queue_adapter = :test }

      it "still ingests the posting as ignored, but never enqueues the expensive AnalysisJob" do
        document
        expect {
          service.call
        }.to change(JobPosting, :count).by(1).and have_enqueued_job(JobBoards::AnalysisJob).exactly(0).times

        expect(JobPosting.last.status).to eq("ignored")
      end
    end

    context "when company ingestion is disabled AND QualityFilter rejects the title" do
      let(:job_data) do
        {
          id: "789",
          title: "Loan Sales Specialist",
          description: "Sales role",
          url: "https://example.com/job789",
          publication_date: "2024-01-01T12:00:00Z",
          company_name: "OneMain Financial",
          candidate_required_location: "Worldwide"
        }
      end
      let(:document) do
        JobBoards::Document.create!(
          signature: "remotive-789", source_id: source.id, job_boards_query_id: query.id, document: job_data.to_json
        )
      end

      before do
        create(:company, name: "OneMain Financial", ingestion_enabled: false)
      end

      it "does not raise AASM::InvalidTransition and marks the document as processed" do
        document
        expect { service.call }.not_to raise_error
        expect(JobPosting.last.status).to eq("ignored")
        expect(document.reload.aasm_state).to eq("processed")
      end
    end

    context "when a document is invalid or cannot be saved" do
      # rubocop:disable-next RSpec/ExampleLength -- integration scenario requires setup + assertions in one example
      it "marks the invalid document as failed and does not starve subsequent documents" do
        bad_document = JobBoards::Document.create!(
          signature: "remotive-bad",
          source_id: source.id,
          job_boards_query_id: query.id,
          document: "not-json-content",
          created_at: 2.days.ago
        )
        good_payload = { id: "good", title: "Valid Eng Role", url: "https://example.com/good",
                         company_name: "Good Co" }.to_json
        good_document = JobBoards::Document.create!(
          signature: "remotive-good",
          source_id: source.id,
          job_boards_query_id: query.id,
          document: good_payload,
          created_at: 1.day.ago
        )

        expect {
          service.call
        }.to change(JobPosting, :count).by(1)

        expect(bad_document.reload.aasm_state).to eq("failed")
        expect(good_document.reload.aasm_state).to eq("processed")
      end
    end

    describe "FIFO ordering" do
      it "processes oldest pending documents first" do
        doc_older = JobBoards::Document.create!(
          signature: "remotive-older", source_id: source.id, job_boards_query_id: query.id,
          document: { id: "older", title: "Older Role", url: "https://example.com/1", company_name: "Old Co" }.to_json,
          created_at: 2.days.ago
        )
        doc_newer = JobBoards::Document.create!(
          signature: "remotive-newer", source_id: source.id, job_boards_query_id: query.id,
          document: { id: "newer", title: "Newer Role", url: "https://example.com/2", company_name: "New Co" }.to_json,
          created_at: 1.day.ago
        )

        service.call(limit: 1)

        expect(doc_older.reload.aasm_state).to eq("processed")
        expect(doc_newer.reload.aasm_state).to be_nil
      end
    end
  end
end
