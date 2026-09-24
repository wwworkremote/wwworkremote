# frozen_string_literal: true

class Applications::CapabilityProbe
  def self.call(observations) = new(observations).call

  def initialize(observations) = @observations = observations.stringify_keys

  def call
    checks = %w[form_detected fields_discoverable upload_supported submit_detected receipt_detected captcha
                listing_loop authentication_wall].index_with { |key|
      boolean(key)
    }
    score = if checks["listing_loop"] || checks["captcha"] then 0 elsif checks["authentication_wall"] || !checks["form_detected"] then 10 else [
      checks.values_at("fields_discoverable", "upload_supported", "submit_detected",
                       "receipt_detected").count(true) * 25, 100
    ].min
            end
    { "provider" => @observations["provider"].presence || "unknown", "grade" => grade(score), "score" => score,
      "checks" => checks, "recommended_action" => recommendation(checks) }
  end

  private

  def boolean(key) = ActiveModel::Type::Boolean.new.cast(@observations[key])

  def grade(score)
    if score < 40
      "D"
    elsif score < 65
      "C"
    else
      score < 90 ? "B" : "A"
    end
  end

  def recommendation(checks)
    return "repair_application_target" if checks["listing_loop"] || !checks["form_detected"]
    return "human_action_required" if checks["captcha"] || checks["authentication_wall"] || !checks["upload_supported"]
    "ready_for_guided_application"
  end
end
