# frozen_string_literal: true

class CreateApplicationCapabilityProbes < ActiveRecord::Migration[8.0]
  # rubocop:disable-next Metrics/MethodLength
  def change
    create_table :application_capability_probes do |t|
      t.references :job_posting, null: false, foreign_key: true
      t.string     :provider, null: false
      t.string     :grade, null: false
      t.integer    :score, null: false
      t.jsonb      :evidence, null: false, default: {}
      t.datetime   :probed_at, null: false
      t.timestamps
    end

    add_index :application_capability_probes,
              %i[job_posting_id probed_at]
  end
end
