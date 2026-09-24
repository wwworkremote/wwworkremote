# frozen_string_literal: true

require "rails_helper"

RSpec.describe Resume::RefreshPlan do
  it "previews additions, changes, and removals without mutating either document" do
    current = { "positions" => { "keep" => { "title" => "Engineer" }, "remove" => { "title" => "Old" } },
                "archetypes" => {} }
    incoming = { "positions" => { "keep" => { "title" => "Staff Engineer" }, "add" => { "title" => "Principal" } },
                 "archetypes" => {} }

    plan = described_class.call(current:, incoming:)

    expect(plan.dig("positions", "added")).to eq([{ "title" => "Principal", "id" => "add" }])
    expect(plan.dig("positions",
                    "changed")).to eq([{ "id" => "keep", "before" => { "title" => "Engineer" },
                                         "after" => { "title" => "Staff Engineer" } }])
    expect(plan.dig("positions", "removed")).to eq([{ "title" => "Old", "id" => "remove" }])
    expect(current.dig("positions", "keep", "title")).to eq("Engineer")
  end
end
