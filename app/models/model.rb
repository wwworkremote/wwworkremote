# frozen_string_literal: true

# ## Schema Information
#
# Table name: `models`
#
# ### Columns
#
# Name                     | Type               | Attributes
# ------------------------ | ------------------ | ---------------------------
# **`id`**                 | `bigint`           | `not null, primary key`
# **`capabilities`**       | `jsonb`            |
# **`context_window`**     | `integer`          |
# **`family`**             | `string`           |
# **`knowledge_cutoff`**   | `date`             |
# **`max_output_tokens`**  | `integer`          |
# **`metadata`**           | `jsonb`            |
# **`modalities`**         | `jsonb`            |
# **`model_created_at`**   | `datetime`         |
# **`name`**               | `string`           | `not null`
# **`pricing`**            | `jsonb`            |
# **`provider`**           | `string`           | `not null`
# **`created_at`**         | `datetime`         | `not null`
# **`updated_at`**         | `datetime`         | `not null`
# **`model_id`**           | `string`           | `not null`
#
# ### Indexes
#
# * `index_models_on_capabilities` (_using_ gin):
#     * **`capabilities`**
# * `index_models_on_family`:
#     * **`family`**
# * `index_models_on_modalities` (_using_ gin):
#     * **`modalities`**
# * `index_models_on_provider_and_model_id` (_unique_):
#     * **`provider`**
#     * **`model_id`**
#
class Model < RubyLLM::ActiveRecord::Model
  def input_price_per_million
    price(:input)
  rescue StandardError
    nil
  end

  def output_price_per_million
    price(:output)
  rescue StandardError
    nil
  end
end
