# frozen_string_literal: true

class CreateResumeRefreshes < ActiveRecord::Migration[8.0]
  # rubocop:disable-next Metrics/MethodLength, Metrics/AbcSize
  def change
    create_table :resume_refreshes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :status, null: false, default: "pending"
      t.jsonb :plan, null: false, default: {}
      t.datetime :approved_at
      t.datetime :rejected_at
      t.text :resolution_note
      t.timestamps
    end

    add_index :resume_refreshes, %i[user_id status]
  end
end
