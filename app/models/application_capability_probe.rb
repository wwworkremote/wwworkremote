# frozen_string_literal: true

# ## Schema Information
#
# Table name: `application_capability_probes`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `bigint`           | `not null, primary key`
# **`evidence`**        | `jsonb`            | `not null`
# **`grade`**           | `string`           | `not null`
# **`probed_at`**       | `datetime`         | `not null`
# **`provider`**        | `string`           | `not null`
# **`score`**           | `integer`          | `not null`
# **`created_at`**      | `datetime`         | `not null`
# **`updated_at`**      | `datetime`         | `not null`
# **`job_posting_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `idx_on_job_posting_id_probed_at_04cff8d868`:
#     * **`job_posting_id`**
#     * **`probed_at`**
# * `index_application_capability_probes_on_job_posting_id`:
#     * **`job_posting_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`job_posting_id => job_postings.id`**
#
class ApplicationCapabilityProbe < ApplicationRecord
  GRADES = %w[A B C D].freeze
  belongs_to :job_posting
  validates :provider, :grade, :score, :probed_at, presence: true
  validates :grade, inclusion: { in: GRADES }
  validates :score, numericality: { in: 0..100 }
end
