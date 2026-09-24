# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  def current_user
    @current_user ||= User.find_or_create_by!(email: Wwwr::Identity.email) do |u|
      u.name = Wwwr::Identity.display_name
      u.password = Wwwr::Identity.password
    end
  end
end
