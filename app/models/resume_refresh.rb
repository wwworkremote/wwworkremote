# frozen_string_literal: true

# ## Schema Information
#
# Table name: `resume_refreshes`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `bigint`           | `not null, primary key`
# **`approved_at`**      | `datetime`         |
# **`plan`**             | `jsonb`            | `not null`
# **`provider`**         | `string`           | `not null`
# **`rejected_at`**      | `datetime`         |
# **`resolution_note`**  | `text`             |
# **`status`**           | `string`           | `default("pending"), not null`
# **`created_at`**       | `datetime`         | `not null`
# **`updated_at`**       | `datetime`         | `not null`
# **`user_id`**          | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_resume_refreshes_on_user_id`:
#     * **`user_id`**
# * `index_resume_refreshes_on_user_id_and_status`:
#     * **`user_id`**
#     * **`status`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
class ResumeRefresh < ApplicationRecord
  STATUSES = %w[pending approved rejected].freeze

  belongs_to :user
  validates :provider, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :plan, presence: true

  scope :pending, -> { where(status: "pending") }

  def approve!(note: nil)
    update!(status: "approved", approved_at: Time.current, resolution_note: note)
  end

  def reject!(note: nil)
    update!(status: "rejected", rejected_at: Time.current, resolution_note: note)
  end
end
