# frozen_string_literal: true

# == Schema Information
#
# Table name: llm_chats
#
#  id                :bigint           not null, primary key
#  cancelled         :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ruby_llm_model_id :bigint
#
# Indexes
#
#  index_llm_chats_on_ruby_llm_model_id  (ruby_llm_model_id)
#
# Foreign Keys
#
#  fk_rails_...  (ruby_llm_model_id => ruby_llm_models.id)
#
class LLMChat < ApplicationRecord
  include ::RubyLLM::ActiveRecord::ActsAs

  acts_as_chat messages: :llm_messages, messages_foreign_key: :llm_chat_id
end
