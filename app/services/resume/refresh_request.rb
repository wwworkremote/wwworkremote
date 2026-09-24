# frozen_string_literal: true

class Resume::RefreshRequest
  def self.call(user:, current:, incoming:, provider:)
    plan = Resume::RefreshPlan.call(current:, incoming:)
    ResumeRefresh.create!(user:, provider:, plan:)
  end
end
