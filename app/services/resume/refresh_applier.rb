# frozen_string_literal: true

class Resume::RefreshApplier
  def self.call(refresh, remove: false)
    new(refresh, remove:).call
  end

  def initialize(refresh, remove:)
    @refresh = refresh
    @remove = remove
  end

  def call
    raise ArgumentError, "refresh is not pending" unless @refresh.status == "pending"
    removals = Array(@refresh.plan.dig("positions", "removed"))
    raise ArgumentError, "removal confirmation required" if removals.any? && !@remove

    ActiveRecord::Base.transaction do
      profile = @refresh.user.career_profile || @refresh.user.create_career_profile!
      apply_positions(profile)
      @refresh.approve!(note: "Applied #{position_count} position changes")
    end
    @refresh
  end

  private

  def apply_positions(profile)
    plan = @refresh.plan.fetch("positions", {})
    Array(plan["added"] + Array(plan["changed"]).map { |change| change.fetch("after") }).each do |data|
      experience = profile.work_experiences.find_or_initialize_by(external_id: data.fetch("id"))
      experience.update!(title: data["title"], company_name: data.dig("company", "name"),
                         location: data.dig("company", "location"), employment_type: data["employment_type"],
                         start_date: data["start_date"], end_date: data["end_date"], summary: data["summary"],
                         action: data["action"], impact: data["impact"], description: data["description"],
                         skills: data["skills"], scope: data["scope"])
    end
    return unless @remove

    Array(plan["removed"]).each { |data| profile.work_experiences.find_by(external_id: data["id"])&.destroy! }
  end

  def position_count
    plan = @refresh.plan.fetch("positions", {})
    Array(plan["added"]).length + Array(plan["changed"]).length + Array(plan["removed"]).length
  end
end
