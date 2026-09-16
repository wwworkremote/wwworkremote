# frozen_string_literal: true

class Api::V0::ApplicationCapabilityProbesController < ApiController
  PROBE_FIELDS = %i[
    form_detected fields_discoverable upload_supported submit_detected
    receipt_detected captcha listing_loop authentication_wall
  ].freeze

  def create
    posting = JobPosting.find(params.expect(:job_posting_id))
    result  = Applications::CapabilityProbe.call(probe_params)
    probe   = record_probe(posting, result)
    render json: result.merge("id" => probe.id), status: :created
  end

  private

  def record_probe(posting, result)
    posting.application_capability_probes.create!(
      provider: result["provider"], grade: result["grade"],
      score: result["score"], evidence: result["checks"], probed_at: Time.current
    )
  end

  def probe_params
    direct_params.merge(observation_params)
  end

  def direct_params
    params.permit(:provider, *PROBE_FIELDS)
  end

  def observation_params
    params.fetch(:observations, {}).permit(*PROBE_FIELDS)
  end
end
