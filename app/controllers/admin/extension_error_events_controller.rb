# frozen_string_literal: true

class Admin::ExtensionErrorEventsController < Admin::ApplicationController
  def update
    report = ExtensionErrorEvent.find(params.expect(:id))
    status = params.expect(extension_error_event: [:status]).fetch(:status)
    unless ExtensionErrorEvent::STATUSES.include?(status)
      return redirect_to admin_extension_workflow_path, alert: "Choose a valid report status."
    end

    report.update!(status: status)
    redirect_to admin_extension_workflow_path(anchor: "friction-reports"), notice: "Friction report marked #{status}."
  end
end
