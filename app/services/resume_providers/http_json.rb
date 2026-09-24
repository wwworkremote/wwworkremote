# frozen_string_literal: true

class ResumeProviders::HttpJson
  LOCAL_CA = File.expand_path("~/.local/share/mkcert/rootCA.pem")

  def initialize(url) = @url = url

  def to_h
    response = Faraday.new(ssl: ssl_options).get(@url)
    raise "resume provider #{@url} returned #{response.status}" unless response.success?

    JSON.parse(response.body)
  end

  private

  def ssl_options
    return {} unless URI(@url).host.to_s.end_with?(".localhost") && File.exist?(LOCAL_CA)

    { ca_file: LOCAL_CA }
  end
end
