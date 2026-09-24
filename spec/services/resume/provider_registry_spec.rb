# frozen_string_literal: true

RSpec.describe Resume::ProviderRegistry do
  it "builds the configured HTTP JSON adapter" do
    provider = described_class.build(name: "http_json", url: "https://profile.example/resume.json")

    expect(provider).to be_a(ResumeProviders::HttpJson)
  end

  it "builds a safe empty adapter for a clone without profile infrastructure" do
    provider = described_class.build(name: "null")

    expect(provider.to_h).to eq("schema_version" => 1, "archetypes" => {}, "positions" => {})
  end

  it "builds the local persisted career profile adapter" do
    expect(described_class.build(name: "career_profile", user: create(:user))).to be_a(ResumeProviders::CareerProfile)
  end

  it "builds the offline file adapter" do
    expect(described_class.build(name: "file_json")).to be_a(ResumeProviders::FileJson)
  end

  it "fails explicitly for an unknown provider" do
    expect { described_class.build(name: "future_provider") }.to raise_error(KeyError, /Unknown resume provider/)
  end
end
