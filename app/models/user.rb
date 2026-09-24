# frozen_string_literal: true

# ## Schema Information
#
# Table name: `users`
#
# ### Columns
#
# Name                       | Type               | Attributes
# -------------------------- | ------------------ | ---------------------------
# **`id`**                   | `bigint`           | `not null, primary key`
# **`email`**                | `string`           | `default(""), not null`
# **`name`**                 | `string`           | `not null`
# **`password_digest`**      | `string`           |
# **`preferred_countries`**  | `text`             | `default([]), is an Array`
# **`slug`**                 | `string`           | `not null`
# **`created_at`**           | `datetime`         | `not null`
# **`updated_at`**           | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_users_on_email` (_unique_):
#     * **`email`**
# * `index_users_on_slug` (_unique_):
#     * **`slug`**
#
class User < ApplicationRecord
  has_secure_password

  has_one :career_profile, dependent: :destroy
  has_many :resumes, dependent: :destroy
  has_many :job_searches, dependent: :destroy
  has_many :user_job_postings, dependent: :destroy
  has_many :job_postings, through: :user_job_postings
  has_many :pipeline_steps, dependent: :destroy
  has_many :human_tasks, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :company_pipeline_steps, dependent: :destroy
  has_many :application_questions, dependent: :destroy
  has_many :application_answer_templates, dependent: :destroy
  has_many :interview_sessions, dependent: :destroy
  has_many :interview_tasks, dependent: :destroy
  has_many :resume_refreshes, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :set_defaults

  # Single-admin app (see ApplicationController#authenticate_admin) -- there
  # is no role column because there is only ever one user.
  def admin?
    true
  end

  def set_defaults
    self.name ||= "User #{SecureRandom.hex(4)}"
    self.slug ||= SecureRandom.hex(8)
    self.preferred_countries = ["US"] if preferred_countries.blank?
  end
end
