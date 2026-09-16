# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Application capability probes" do
  it "accepts the extension's observation payload and grades a complete form" do
    posting = create(:job_posting)

    post "/api/v0/job_postings/#{posting.id}/application_capability_probes", params: {
      provider: "greenhouse",
      observations: {
        form_detected: true, fields_discoverable: true, upload_supported: true,
        submit_detected: true, receipt_detected: true, captcha: false,
        listing_loop: false, authentication_wall: false
      }
    }

    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to include("provider" => "greenhouse", "grade" => "A", "score" => 100)
    expect(posting.application_capability_probes.order(:id).last.evidence).to include("form_detected" => true)
  end
end
