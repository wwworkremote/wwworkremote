# frozen_string_literal: true

class JobIntakesController < ApplicationController
  def create
    result = Applications::UrlIntake.call(url: params[:url], user: current_user)
    if result[:success]
      redirect_to user_job_posting_path(result[:application]),
                  notice: "Job added. Next: #{result[:cycle_plan][:next_step].humanize}."
    else
      redirect_to root_path, alert: result[:error]
    end
  end
end
