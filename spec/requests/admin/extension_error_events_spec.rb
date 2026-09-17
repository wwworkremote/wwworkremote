# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::ExtensionErrorEvents" do
  it "updates a friction report lifecycle status" do
    report = ExtensionErrorEvent.create!(build_version: "1.36.8", event_name: "friction_report",
                                         occurred_at: Time.current, context: {})

    patch admin_extension_error_event_path(report), params: { extension_error_event: { status: "resolved" } }

    expect(response).to redirect_to(admin_extension_workflow_path(anchor: "friction-reports"))
    expect(report.reload.status).to eq("resolved")
  end
end
