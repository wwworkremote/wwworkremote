# frozen_string_literal: true

# ## Schema Information
#
# Table name: `domains`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `bigint`           | `not null, primary key`
# **`name`**            | `citext`           | `not null`
# **`created_at`**      | `datetime`         | `not null`
# **`updated_at`**      | `datetime`         | `not null`
# **`root_domain_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_domains_on_name` (_unique_):
#     * **`name`**
# * `index_domains_on_root_domain_id`:
#     * **`root_domain_id`**
#
FactoryBot.define do
  factory :domain do
    sequence(:name) { |n| "test-domain-#{n}.com" }
  end
end
