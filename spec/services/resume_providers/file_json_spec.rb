# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResumeProviders::FileJson do
  it "loads a JSON object from an explicit export" do
    path = Rails.root.join("tmp", "resume-provider-spec-#{SecureRandom.hex(4)}.json")
    File.write(path, JSON.generate("archetypes" => {}, "positions" => { "role" => { "title" => "Engineer" } }))

    expect(described_class.new(path).to_h).to include("schema_version" => 1, "archetypes" => {},
                                                      "positions" => { "role" => { "title" => "Engineer" } })
  ensure
    File.delete(path) if path&.file?
  end

  it "fails loudly for malformed JSON" do
    path = Rails.root.join("tmp", "resume-provider-spec-#{SecureRandom.hex(4)}.json")
    File.write(path, "not json")

    expect { described_class.new(path).to_h }.to raise_error(JSON::ParserError, /Invalid resume JSON/)
  ensure
    File.delete(path) if path&.file?
  end
end
