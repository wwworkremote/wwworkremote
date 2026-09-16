# frozen_string_literal: true

class AddOutcomeToInterviewSessions < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    unless column_exists?(:interview_sessions, :outcome)
      add_column :interview_sessions, :outcome, :string, null: false, default: "pending"
    end
    return if index_exists?(:interview_sessions, :outcome)

    add_index :interview_sessions, :outcome, algorithm: :concurrently
  end
end
