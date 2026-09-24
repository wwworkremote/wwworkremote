# frozen_string_literal: true

class Admin::ResumeRefreshesController < Admin::ApplicationController
  def index
    @refreshes = current_user.resume_refreshes.order(created_at: :desc)
  end

  def create
    current = ResumeProviders::CareerProfile.new(user: current_user).to_h
    incoming = Resume::Source.new(user: current_user).to_h
    Resume::RefreshRequest.call(user: current_user, current:, incoming:,
                                provider: ENV.fetch("WWWR_RESUME_PROVIDER", "http_json"))
    redirect_to admin_resume_refreshes_path, notice: "Refresh preview created. Review it before applying changes."
  rescue StandardError => e
    redirect_to admin_resume_refreshes_path, alert: "Refresh failed: #{e.message}"
  end

  def approve
    refresh = current_user.resume_refreshes.pending.find(params.expect(:id))
    Resume::RefreshApplier.call(refresh, remove: params[:confirm_removals] == "1")
    redirect_to admin_resume_refreshes_path, notice: "Resume refresh applied."
  rescue ArgumentError => e
    redirect_to admin_resume_refreshes_path, alert: e.message
  end

  def reject
    current_user.resume_refreshes.pending.find(params.expect(:id)).reject!(note: params[:resolution_note])
    redirect_to admin_resume_refreshes_path, notice: "Refresh rejected; existing profile retained."
  end
end
