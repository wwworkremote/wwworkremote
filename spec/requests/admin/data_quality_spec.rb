# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin data quality" do
  it "renders ranked findings and supports JSON export" do
    get admin_data_quality_path
    expect(response).to be_successful
    expect(response.body).to include("Data quality")
    expect(response.body).to include("Apply exact matches")

    get admin_data_quality_path(format: :json)
    expect(response).to be_successful
    expect(response.media_type).to eq("application/json")
    expect(response.parsed_body).to be_an(Array)
  end
end
