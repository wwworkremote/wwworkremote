# frozen_string_literal: true

class ResumeProviders::FileJson
  DEFAULT_PATH = Rails.root.join("tmp/resume.json").freeze

  def initialize(path = ENV.fetch("WWWR_RESUME_FILE", DEFAULT_PATH.to_s))
    @path = Pathname(path)
  end

  def to_h
    raise Errno::ENOENT, @path unless @path.file?

    document = JSON.parse(@path.read)
    raise TypeError, "Resume document must be a JSON object" unless document.is_a?(Hash)

    Resume::DocumentContract.call(document, provider: self.class.name.demodulize.underscore)
  rescue JSON::ParserError => e
    raise JSON::ParserError, "Invalid resume JSON in #{@path}: #{e.message}"
  end
end
