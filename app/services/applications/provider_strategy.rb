# frozen_string_literal: true

# Provider-specific execution policy. Pure data: no browser or LLM calls.
# Runners use this contract to decide what to capture and when to pause.
class Applications::ProviderStrategy
  STRATEGIES = {
    "linkedin" => { label: "LinkedIn Easy Apply", application_method: "easy_apply", auto_fill: true,
                    captures: %w[answers agreements receipt], human_gate: "submit" },
    "indeed" => { label: "Indeed", application_method: "easy_apply", auto_fill: true,
                  captures: %w[answers agreements receipt], human_gate: "submit" },
    "greenhouse" => { label: "Greenhouse", application_method: "external_site", auto_fill: true,
                      captures: %w[answers agreements receipt], human_gate: "submit" },
    "lever" => { label: "Lever", application_method: "external_site", auto_fill: true,
                 captures: %w[answers agreements receipt], human_gate: "submit" },
    "jobvite" => { label: "Jobvite", application_method: "external_site", auto_fill: true,
                   captures: %w[answers agreements receipt], human_gate: "submit" },
    "workday" => { label: "Workday", application_method: "external_site", auto_fill: false,
                   captures: %w[answers agreements receipt], human_gate: "sensitive_fields_and_submit" }
  }.freeze

  def self.for(provider)
    new(provider)
  end

  def initialize(provider)
    @provider = provider.to_s.downcase
  end

  def to_h
    STRATEGIES.fetch(@provider, fallback.merge(provider: @provider))
  end

  private

  def fallback
    { label: "Unknown provider", application_method: "external_site", auto_fill: false,
      captures: %w[answers agreements receipt], human_gate: "all_fields_and_submit" }
  end
end
