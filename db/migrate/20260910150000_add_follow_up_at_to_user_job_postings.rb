# frozen_string_literal: true

class AddFollowUpAtToUserJobPostings < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :user_job_postings, :follow_up_at, :datetime
    add_index :user_job_postings, :follow_up_at, algorithm: :concurrently
  end
end
