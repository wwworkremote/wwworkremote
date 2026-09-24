# frozen_string_literal: true

class Resume::DocumentContract
  CURRENT_VERSION = 1

  def self.call(document, provider:)
    new(document, provider:).call
  end

  def initialize(document, provider:)
    @document = document
    @provider = provider
  end

  def call
    fail_with("document", "Hash") unless @document.is_a?(Hash)
    document = @document.deep_dup
    document["schema_version"] ||= CURRENT_VERSION
    fail_with("schema_version", CURRENT_VERSION) unless document["schema_version"] == CURRENT_VERSION
    validate_hash!(document, "archetypes")
    validate_hash!(document, "positions")
    validate_positions!(document["positions"])
    document
  end

  private

  def validate_hash!(document, key)
    fail_with(key, "Hash") unless document[key].is_a?(Hash)
  end

  def validate_positions!(positions)
    positions.each do |key, value|
      fail_with("positions[#{key}]", "Hash") unless value.is_a?(Hash)
      next unless value["id"] && value["id"].to_s != key.to_s

      fail_with("positions[#{key}] stable id", key)
    end
  end

  def fail_with(field, expected)
    raise ArgumentError, "#{@provider} resume document #{field} must be #{expected}"
  end
end
