# frozen_string_literal: true

class ResumeProviders::Null
  def to_h = { "schema_version" => Resume::DocumentContract::CURRENT_VERSION, "archetypes" => {}, "positions" => {} }
end
