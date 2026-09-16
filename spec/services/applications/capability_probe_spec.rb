# frozen_string_literal: true

require "rails_helper"

RSpec.describe Applications::CapabilityProbe do
  it "ranks a complete form as A" do
    result = described_class.call(
      provider: "greenhouse", form_detected: true, fields_discoverable: true,
      upload_supported: true, submit_detected: true, receipt_detected: true
    )
    expect(result).to include(
      "grade" => "A", "score" => 100, "recommended_action" => "ready_for_guided_application"
    )
  end

  it "blocks listing loops as D" do
    result = described_class.call(provider: "jobicy", listing_loop: true)
    expect(result).to include(
      "grade" => "D", "score" => 0, "recommended_action" => "repair_application_target"
    )
  end

  it "routes CAPTCHA and upload limits to a human" do
    result = described_class.call(form_detected: true, fields_discoverable: true, captcha: true)
    expect(result["recommended_action"]).to eq("human_action_required")
  end
end
