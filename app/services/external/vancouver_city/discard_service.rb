# frozen_string_literal: true

class External::VancouverCity::DiscardService < ApplicationService
  attr_reader :api_key

  def initialize(api_key:)
    super()
    @api_key = api_key
  end

  def call
    return failure(["Unsupported API: #{api_key}"]) unless External::ApiHelper.supported_api?(api_key)

    discarded_count = 0

    Facility.external.kept.find_each do |facility|
      facility.discard_reason = :sync_removed
      facility.discard!
      discarded_count += 1
    end

    success({ discarded_count: discarded_count })
  end
end
