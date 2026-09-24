# frozen_string_literal: true

class Admin::DataQualityController < Admin::ApplicationController
  def index
    @findings = DataQuality::Audit.call
    @selected_field = params[:field].presence_in(@findings.pluck(:field)) || @findings.first&.fetch(:field)
    @examples = examples_for(@selected_field)
    respond_to do |format|
      format.html
      format.json { render json: @selected_field == "Company" ? DataQuality::CompanyReconciler.candidates : @findings }
    end
  end

  def update
    posting = JobPosting.find(params.expect(:id))
    posting.update!(company_id: params.expect(job_posting: [:company_id]).fetch(:company_id))
    redirect_to admin_data_quality_path(field: "Company"), notice: "Company reconciled for #{posting.title}."
  end

  def reconcile_companies
    count = DataQuality::CompanyReconciler.apply!
    redirect_to admin_data_quality_path(field: "Company"), notice: "Reconciled #{count} unambiguous company matches."
  end

  private

  def examples_for(field)
    return JobPosting.none if field.blank?

    scope = JobPosting.includes(:company).order(created_at: :desc)
    case field
    when "Company" then scope.where(company_id: nil).where(company_name: [nil, ""])
    when "Company candidate" then scope.where(id: DataQuality::CompanyReconciler.candidates(limit: 50).select(:posting_id))
    when "Description" then scope.where(body: [nil, ""])
    when "Location" then scope.where(location: [nil, ""])
    when "Application URL" then scope.where(target_url: [nil, ""])
    when "Published date" then scope.where(published_at: nil)
    when "Source" then scope.where(source_id: nil)
    when "Signature" then scope.where(signature: [nil, ""])
    when "Duplicate signature"
      duplicate_signatures = JobPosting.where.not(signature: [nil,
                                                              ""]).group(:signature).having("count(*) > 1").pluck(:signature)
      scope.where(signature: duplicate_signatures)
    else JobPosting.none
    end.limit(50)
  end
end
