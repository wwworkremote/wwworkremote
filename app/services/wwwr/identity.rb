# frozen_string_literal: true

# Runtime identity belongs to the local operator, not the public codebase.
module Wwwr::Identity
  module_function

  def email = ENV.fetch("WWWR_ADMIN_EMAIL", ENV.fetch("ADMIN_EMAIL", I18n.t("wwr.identity.default_email")))

  def password
    ENV.fetch("WWWR_ADMIN_PASSWORD", ENV.fetch("ADMIN_PASSWORD", I18n.t("wwr.identity.default_password")))
  end

  def profile_url
    ENV.fetch("WWWR_PROFILE_URL", ENV.fetch("JUST3WS_RESUME_URL", I18n.t("wwr.identity.default_profile_url")))
  end

  def display_name
    ENV.fetch("WWWR_DISPLAY_NAME", ENV.fetch("ADMIN_NAME", I18n.t("wwr.identity.default_display_name")))
  end
end
