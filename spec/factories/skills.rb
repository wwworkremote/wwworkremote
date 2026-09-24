# frozen_string_literal: true

# ## Schema Information
#
# Table name: `skills`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `bigint`           | `not null, primary key`
# **`category`**     | `string`           |
# **`description`**  | `text`             |
# **`embedding`**    | `vector(768)`      |
# **`name`**         | `string`           | `not null`
# **`created_at`**   | `datetime`         | `not null`
# **`updated_at`**   | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_skills_on_embedding_hnsw` (_using_ hnsw):
#     * **`((embedding)::halfvec(768)) halfvec_cosine_ops`**
# * `index_skills_on_name` (_unique_):
#     * **`name`**
#
FactoryBot.define do
  factory :skill do
    sequence(:name) { |n| "Skill #{n}" }
  end
end
