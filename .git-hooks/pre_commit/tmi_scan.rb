# frozen_string_literal: true

# Runs bin/tmi-scan to detect sensitive strings, live interview mentions, and PII.
class Overcommit::Hook::PreCommit::TmiScan < Overcommit::Hook::PreCommit::Base
  def run
    result = execute(%w[bin/tmi-scan])
    return :pass if result.success?

    [:warn, result.stderr.presence || result.stdout]
  end
end
