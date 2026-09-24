# frozen_string_literal: true

class Applications::StaleClosureJob < ApplicationJob
  queue_as :low

  def perform
    result = Applications::StaleClosure.call
    Rails.logger.info("[Applications::StaleClosure] " \
                      "closed=#{result[:count]} cutoff=#{result[:cutoff].iso8601} " \
                      "application_ids=#{result[:application_ids].join(',')}")
    result
  end
end
