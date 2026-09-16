# frozen_string_literal: true

class LinkExtensionFrictionToWorkflow < ActiveRecord::Migration[7.1]
  # rubocop:disable-next Metrics/MethodLength, Metrics/AbcSize
  def change
    safety_assured do
      change_table :extension_error_events, bulk: true do |t|
        t.string :status, null: false, default: "open"
        t.string :signature
        t.references :job_posting, foreign_key: true
        t.references :user_job_posting, foreign_key: true
        t.references :guided_session, foreign_key: true
      end
    end
    safety_assured do
      add_index :extension_error_events, :signature
      add_index :extension_error_events, :status
    end
  end
end
