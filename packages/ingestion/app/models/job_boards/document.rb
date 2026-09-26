# frozen_string_literal: true

# == Schema Information
#
# Table name: job_boards_documents
#
#  id                  :uuid             not null, primary key
#  aasm_state          :string
#  document            :text             default(""), not null
#  signature           :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  job_boards_query_id :integer          not null
#  source_id           :integer          not null
#
# Indexes
#
#  index_job_boards_documents_on_aasm_state           (aasm_state)
#  index_job_boards_documents_on_job_boards_query_id  (job_boards_query_id)
#  index_job_boards_documents_on_signature            (signature) UNIQUE
#  index_job_boards_documents_on_source_id            (source_id)
#
# Raw ingestion staging buffer: stores fetched/scraped job payloads before
# JobBoards::Syncer maps and normalizes them into JobPostings.
#
# State lifecycle (`aasm_state` string column):
# - "pending" (or nil): Raw payload ingested, awaiting synchronization.
# - "processed": Successfully mapped and persisted as a JobPosting (or shielded).
# - "failed": Permanent failure during sync (corrupted JSON, unrecoverable validation error).
class JobBoards::Document < ApplicationRecord
  belongs_to :job_boards_source, class_name: "JobBoards::Source", foreign_key: "source_id",
                                 counter_cache: :job_boards_documents_count, inverse_of: :job_boards_documents
  belongs_to :job_boards_query, class_name: "JobBoards::Query"

  validates :signature, presence: true, uniqueness: true
  validates :source_id, presence: true

  scope :pending, -> { where(aasm_state: ["pending", nil]) }
  scope :processed, -> { where(aasm_state: "processed") }
  scope :failed, -> { where(aasm_state: "failed") }
end
