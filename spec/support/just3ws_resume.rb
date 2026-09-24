# frozen_string_literal: true

# Posting-page specs should exercise the Rails view without making an
# unrecorded request to the sibling canonical resume service. Individual
# resume-import specs provide their own, richer stubs when they need them.
RSpec.configure do |config|
  config.before do
    stub_request(:get, %r{https://(just3ws|profile)\.localhost/resume\.json})
      .to_return(status: 200, body: { "archetypes" => {} }.to_json,
                 headers: { "Content-Type" => "application/json" })
  end
end
