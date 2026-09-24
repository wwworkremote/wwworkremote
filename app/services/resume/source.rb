# frozen_string_literal: true

# just3ws publishes its whole `_data/resume` tree at /resume.json --
# `{{ site.data.resume | jsonify }}` -- so one request carries every section the
# importer used to open a separate file for. See docs/just3ws-interop-protocol.md
# section 2. Fetched once and memoised; the importer reads sections out of it.
class Resume::Source
  DEFAULT_URL = "https://profile.localhost/resume.json"
  def initialize(url: nil, user: nil)
    @url = url || Wwwr::Identity.profile_url
    @user = user
  end

  # Raises rather than returning a partial document: a half-import silently
  # half-overwrites a good profile, which is worse than not importing at all.
  def to_h
    @to_h ||= begin
      provider = Resume::ProviderRegistry.build(url: @url, user: @user)
      Resume::DocumentContract.call(provider.to_h, provider: provider.class.name.demodulize.underscore)
    end
  end
end
