# frozen_string_literal: true

namespace :data do
  # Usage Example:
  #    rake json:export[./db/facilities.json]
  desc "Create facilities from db/fake_data.json JSON file"
  task seed_fake: :environment do
    abort "This script can only be run on development environment" unless Rails.env.development?

    logger = Rails.logger
    logger.extend(ActiveSupport::Logger.broadcast(ActiveSupport::Logger.new(STDOUT)))
    logger.formatter = nil

    logger.info "[seed_fake] Loading new facilities from database."
    new_facilities = load_fake_data.dig("v1", "facilities")
    if new_facilities.blank?
      logger.error "[seed_fake] Failed to load new facilities."
      abort
    end

    logger.info "[seed_fake] Creating #{new_facilities.count} facilities."

    result = []
    new_facilities.map do |facility_hash|
      next if Facility.find_by(id: facility_hash["id"]).present?

      result << Facility.create(facility_hash)
    end

    logger.error "[seed_fake] Failed to add facilities." unless result.all?

    logger.info "[seed_fake] Done creating facilities."
  end

  def load_fake_data
    json_data_location = Rails.root.join("db", "fake_data.json")
    JSON.load(json_data_location)
  end
end
