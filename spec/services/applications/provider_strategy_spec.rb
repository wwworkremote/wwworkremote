# frozen_string_literal: true

RSpec.describe Applications::ProviderStrategy do
  it "gives Easy Apply providers a resumable policy with a submit gate" do
    strategy = described_class.for("LinkedIn").to_h

    expect(strategy).to include(label: "LinkedIn Easy Apply", application_method: "easy_apply", auto_fill: true)
    expect(strategy[:captures]).to include("agreements", "receipt")
    expect(strategy[:human_gate]).to eq("submit")
  end

  it "fails closed for unknown providers" do
    strategy = described_class.for("new-ats").to_h

    expect(strategy).to include(provider: "new-ats", auto_fill: false)
    expect(strategy[:human_gate]).to eq("all_fields_and_submit")
  end

  it "treats Jobvite as a resumable, receipt-backed external application" do
    strategy = described_class.for("jobvite").to_h

    expect(strategy).to include(label: "Jobvite", application_method: "external_site", auto_fill: true)
    expect(strategy[:captures]).to include("answers", "agreements", "receipt")
    expect(strategy[:human_gate]).to eq("submit")
  end
end
