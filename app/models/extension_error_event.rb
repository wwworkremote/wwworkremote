# frozen_string_literal: true

# == Schema Information
#
# Table name: extension_error_events
#
#  id                   :bigint           not null, primary key
#  build_version        :string           not null
#  context              :jsonb            not null
#  error_message        :text
#  error_name           :string
#  event_name           :string           not null
#  guided_session_token :string
#  occurred_at          :datetime         not null
#  page_host            :string
#  phase                :string
#  provider             :string
#  recoverable          :boolean          default(FALSE), not null
#  signature            :string
#  status               :string           default("open"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  guided_session_id    :bigint
#  job_posting_id       :bigint
#  trace_id             :string
#  user_job_posting_id  :bigint
#
# Indexes
#
#  index_extension_error_events_on_event_name_and_occurred_at  (event_name,occurred_at)
#  index_extension_error_events_on_guided_session_id           (guided_session_id)
#  index_extension_error_events_on_guided_session_token        (guided_session_token)
#  index_extension_error_events_on_job_posting_id              (job_posting_id)
#  index_extension_error_events_on_signature                   (signature)
#  index_extension_error_events_on_status                      (status)
#  index_extension_error_events_on_trace_id                    (trace_id)
#  index_extension_error_events_on_user_job_posting_id         (user_job_posting_id)
#
# Foreign Keys
#
#  fk_rails_...  (guided_session_id => guided_sessions.id)
#  fk_rails_...  (job_posting_id => job_postings.id)
#  fk_rails_...  (user_job_posting_id => user_job_postings.id)
#
class ExtensionErrorEvent < ApplicationRecord
  STATUSES = %w[open acknowledged resolved dismissed].freeze

  belongs_to :job_posting, optional: true
  belongs_to :user_job_posting, optional: true
  belongs_to :guided_session, optional: true

  validates :build_version, :event_name, :occurred_at, presence: true
  validates :status, inclusion: { in: STATUSES }
end
