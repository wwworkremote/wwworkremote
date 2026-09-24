# frozen_string_literal: true

class Api::JobIntakesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    result = Applications::UrlIntake.call(url: params[:url], user: current_user, attributes: intake_params)
    if result[:success]
      render json: { success: true, lead_id: result[:lead].id, job_posting_id: result[:job_posting].id,
                     application_id: result[:application].id, guided_session_id: result[:guided_session].id,
                     cycle_plan: result[:cycle_plan] }, status: :created
    else
      render json: result, status: :unprocessable_content
    end
  end

  private

  def intake_params
    params.permit(:title, :company_name, :location, :raw_html, discovery: {}, data: {}, company: [:name]).to_h
  end
end
