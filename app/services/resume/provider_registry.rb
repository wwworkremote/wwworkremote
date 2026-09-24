# frozen_string_literal: true

class Resume::ProviderRegistry
  PROVIDERS = {
    "career_profile" => ::ResumeProviders::CareerProfile,
    "file_json" => ::ResumeProviders::FileJson,
    "http_json" => ::ResumeProviders::HttpJson,
    "null" => ::ResumeProviders::Null
  }.freeze

  def self.build(name: ENV.fetch("WWWR_RESUME_PROVIDER", "http_json"), url: Resume::Source::DEFAULT_URL, user: nil)
    provider = PROVIDERS.fetch(name.to_s) { raise KeyError, "Unknown resume provider: #{name}" }
    case provider.name
    when "ResumeProviders::Null" then provider.new
    when "ResumeProviders::CareerProfile" then provider.new(user: user)
    when "ResumeProviders::FileJson" then provider.new
    else provider.new(url)
    end
  end
end
