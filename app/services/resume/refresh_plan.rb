# frozen_string_literal: true

class Resume::RefreshPlan
  def self.call(current:, incoming:)
    new(current:, incoming:).call
  end

  def initialize(current:, incoming:)
    @current = current
    @incoming = incoming
  end

  def call
    {
      "positions" => changes("positions"),
      "archetypes" => changes("archetypes")
    }
  end

  private

  def changes(section)
    current = @current.fetch(section, {})
    incoming = @incoming.fetch(section, {})
    {
      "added" => (incoming.keys - current.keys).map { |key| incoming.fetch(key).merge("id" => key) },
      "changed" => (incoming.keys & current.keys).filter_map do |key|
        next if incoming.fetch(key) == current.fetch(key)

        { "id" => key, "before" => current.fetch(key), "after" => incoming.fetch(key) }
      end,
      "removed" => (current.keys - incoming.keys).map { |key| current.fetch(key).merge("id" => key) }
    }
  end
end
