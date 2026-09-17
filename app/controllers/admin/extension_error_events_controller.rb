# frozen_string_literal: true

class Admin::ExtensionErrorEventsController < Admin::ApplicationController
  def update
    report = ExtensionErrorEvent.find(params.expect(:id))
    return invalid_status unless update_report(report)

    redirect_to admin_extension_workflow_path(anchor: "friction-reports"),
                notice: "Friction report marked #{report_status}."
  end

  private

  def update_report(report)
    return false unless ExtensionErrorEvent::STATUSES.include?(report_status)

    report.update!(status: report_status)
  end

  def report_status
    params.expect(extension_error_event: [:status]).fetch(:status)
  end

  def invalid_status
    redirect_to admin_extension_workflow_path, alert: "Choose a valid report status."
  end
end
