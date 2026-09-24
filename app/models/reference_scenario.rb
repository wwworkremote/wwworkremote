# frozen_string_literal: true

# ## Schema Information
#
# Table name: `reference_scenarios`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `bigint`           | `not null, primary key`
# **`provider`**     | `string`           | `not null`
# **`created_at`**   | `datetime`         | `not null`
# **`updated_at`**   | `datetime`         | `not null`
# **`scenario_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_reference_scenarios_on_provider` (_unique_):
#     * **`provider`**
# * `index_reference_scenarios_on_scenario_id` (_unique_):
#     * **`scenario_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`scenario_id => scenarios.id`**
#
class ReferenceScenario < ApplicationRecord
  belongs_to :scenario

  validates :provider, presence: true, uniqueness: true
  validates :scenario_id, uniqueness: true
  validate :scenario_provider_matches

  private

  def scenario_provider_matches
    return if scenario.blank? || provider == scenario.provider

    errors.add(:provider, "must match the Scenario provider")
  end
end
