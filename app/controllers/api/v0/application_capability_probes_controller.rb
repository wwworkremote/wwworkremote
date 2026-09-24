# frozen_string_literal: true

class Api::V0::ApplicationCapabilityProbesController < ApiController
  def create
    posting = JobPosting.find(params.expect(:job_posting_id))
    result = Applications::CapabilityProbe.call(probe_params)
    probe = posting.application_capability_probes.create!(provider: result["provider"], grade: result["grade"],
                                                          score: result["score"], evidence: result["checks"], probed_at: Time.current)
    render json: result.merge("id" => probe.id), status: :created
  end

  private

  def probe_params
    permitted = params.permit(:provider, :form_detected, :fields_discoverable, :upload_supported, :submit_detected,
                              :receipt_detected, :captcha, :listing_loop, :authentication_wall)
    permitted.merge(params.fetch(:observations, {}).permit(:form_detected, :fields_discoverable, :upload_supported,
                                                           :submit_detected, :receipt_detected, :captcha, :listing_loop, :authentication_wall))
  end
end
