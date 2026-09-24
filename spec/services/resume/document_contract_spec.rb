# frozen_string_literal: true

require "rails_helper"

RSpec.describe Resume::DocumentContract do
  it "versions a legacy document" do
    expect(described_class.call({ "archetypes" => {}, "positions" => {} }, provider: "file_json"))
      .to include("schema_version" => 1)
  end

  it "rejects invalid required sections" do
    expect { described_class.call({ "archetypes" => [] }, provider: "http_json") }
      .to raise_error(ArgumentError, /http_json.*archetypes.*Hash/)
  end

  it "rejects positions whose id differs from their stable key" do
    document = { "archetypes" => {}, "positions" => { "role-a" => { "id" => "role-b" } } }
    expect { described_class.call(document, provider: "career_profile") }
      .to raise_error(ArgumentError, /positions\[role-a\].*stable id/)
  end
end
