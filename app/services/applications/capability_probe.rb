# frozen_string_literal: true

class Applications::CapabilityProbe
  OBSERVATION_KEYS = %w[
    form_detected fields_discoverable upload_supported submit_detected
    receipt_detected captcha listing_loop authentication_wall
  ].freeze

  def self.call(observations) = new(observations).call

  def initialize(observations)
    @observations = observations.stringify_keys
  end

  def call
    checks = OBSERVATION_KEYS.index_with { |key| boolean(key) }
    score  = compute_score(checks)
    payload(checks, score)
  end

  private

  def payload(checks, score)
    { "provider" => @observations["provider"].presence || "unknown",
      "grade" => grade(score), "score" => score,
      "checks" => checks, "recommended_action" => recommendation(checks) }
  end

  def compute_score(checks)
    return 0 if checks["listing_loop"] || checks["captcha"]
    return 10 if checks["authentication_wall"] || !checks["form_detected"]

    capability_score(checks)
  end

  def capability_score(checks)
    raw = checks.values_at(
      "fields_discoverable", "upload_supported", "submit_detected", "receipt_detected"
    ).count(true) * 25
    [raw, 100].min
  end

  def boolean(key) = ActiveModel::Type::Boolean.new.cast(@observations[key])

  def grade(score)
    return "D" if score < 40
    return "C" if score < 65

    score < 90 ? "B" : "A"
  end

  def recommendation(checks)
    return "repair_application_target" if checks["listing_loop"] || !checks["form_detected"]
    return "human_action_required" if checks["captcha"] || checks["authentication_wall"] || !checks["upload_supported"]

    "ready_for_guided_application"
  end
end
