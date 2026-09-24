# frozen_string_literal: true

# ## Schema Information
#
# Table name: `companies`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `bigint`           | `not null, primary key`
# **`disposition`**         | `string`           |
# **`glassdoor_data`**      | `jsonb`            |
# **`ingestion_enabled`**   | `boolean`          | `default(TRUE), not null`
# **`last_declined_at`**    | `datetime`         |
# **`name`**                | `string`           |
# **`sentiment_score`**     | `float`            |
# **`slug`**                | `string`           |
# **`status`**              | `string`           |
# **`toxic_culture_flag`**  | `boolean`          |
# **`created_at`**          | `datetime`         | `not null`
# **`updated_at`**          | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_companies_on_name` (_unique_):
#     * **`name`**
# * `index_companies_on_name_trgm` (_using_ gin):
#     * **`name`**
# * `index_companies_on_slug` (_unique_):
#     * **`slug`**
#
FactoryBot.define do
  factory :company do
    name { "Company #{SecureRandom.hex(4)}" }
    slug { "company-#{SecureRandom.hex(4)}" }
    status { "none" }
  end
end
