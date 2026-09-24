# frozen_string_literal: true

# ## Schema Information
#
# Table name: `hacker_news_v0_jobstories`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`by`**          | `string`           |
# **`data`**        | `jsonb`            | `not null`
# **`score`**       | `integer`          |
# **`text`**        | `text`             |
# **`time`**        | `integer`          |
# **`title`**       | `string`           |
# **`url`**         | `string`           |
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_hacker_news_v0_jobstories_on_id` (_unique_):
#     * **`id`**
#
class HackerNews::V0::Jobstory < ApplicationRecord
  include PgSearch::Model

  multisearchable against: %i[title text]

  self.primary_key = :id
end
