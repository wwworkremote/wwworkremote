# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResumeProviders::CareerProfile do
  it "exports local profile, persona, and stable position data" do
    user = create(:user, name: "Mike Example", email: "mike@example.com")
    profile = create(:career_profile, user: user, skills: "Ruby, Rails", experience_level: "staff",
                                      goals: "Build useful systems", location_info: { "display" => "Chicago, IL" },
                                      contact_info: { "linkedin" => "https://linkedin.com/in/mike" }, github_url: "https://github.com/mike")
    create(:work_experience, career_profile: profile, external_id: "acme-2024",
                             title: "Staff Engineer", company_name: "Acme", summary: "Led platform work", start_date: Date.new(2024, 1, 1))

    document = described_class.new(user: user).to_h

    expect(document["schema_version"]).to eq(1)
    expect(document.dig("profile", "name")).to eq("Mike Example")
    expect(document.dig("profile", "location", "display")).to eq("Chicago, IL")
    expect(document.dig("archetypes", "default", "core_skills")).to eq(%w[Ruby Rails])
    expect(document.dig("archetypes", "default", "featured_positions")).to eq([{ "id" => "acme-2024" }])
    expect(document.dig("positions", "acme-2024")).to include("title" => "Staff Engineer", "start_date" => "2024-01-01")
  end

  it "returns the safe empty document when no local profile exists" do
    expect(described_class.new(user: create(:user)).to_h).to eq("schema_version" => 1, "archetypes" => {},
                                                                "positions" => {})
  end
end
