# frozen_string_literal: true

# ## Schema Information
#
# Table name: `sources`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`event`**       | `jsonb`            | `not null`
# **`payload`**     | `jsonb`            | `not null`
# **`signature`**   | `string`           | `not null`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`origin_id`**   | `bigint`           |
#
# ### Indexes
#
# * `index_sources_on_event` (_using_ gin):
#     * **`event`**
# * `index_sources_on_origin_id`:
#     * **`origin_id`**
# * `index_sources_on_payload` (_using_ gin):
#     * **`payload`**
# * `index_sources_on_signature` (_unique_):
#     * **`signature`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`origin_id => origins.id`**
#
FactoryBot.define do
  factory :source do
    sequence(:signature) { |n| "source-#{n}" }
  end
end
