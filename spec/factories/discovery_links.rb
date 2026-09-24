# frozen_string_literal: true

# ## Schema Information
#
# Table name: `discovery_links`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `bigint`           | `not null, primary key`
# **`board_name`**     | `string`           |
# **`error_message`**  | `text`             |
# **`status`**         | `string`           |
# **`url`**            | `string`           |
# **`created_at`**     | `datetime`         | `not null`
# **`updated_at`**     | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_discovery_links_on_url` (_unique_):
#     * **`url`**
#
FactoryBot.define do
  factory :discovery_link do
    board_name { "MyString" }
    url { "MyString" }
    status { "MyString" }
  end
end
