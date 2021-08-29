# frozen_string_literal: true

require "colorize"

namespace :data do
  desc "Create facilities from db/fake_data.json JSON file"
  task seed_fake: :environment do
    abort "This script can only be run on development environment" unless Rails.env.development?

    stdout_logger = ActiveSupport::Logger.new($stdout)
    stdout_logger.level = :info
    stdout_logger.formatter = proc do |severity, _time, progname, msg|
      header = "["
      header += "#{progname} - " if progname.present?

      header += case severity
                when "INFO"
                  severity.green
                when "WARN"
                  severity.yellow
                when "ERROR"
                  severity.light_red
                else
                  severity
      end
      header += "]"

      "#{header} #{msg}\n"
    end

    logger = Rails.logger
    logger.extend(ActiveSupport::Logger.broadcast(stdout_logger))

    logger.info "[seed_fake] Loading new facilities from database."
    new_facilities = load_fake_data.dig("v1", "facilities")
    if new_facilities.blank?
      logger.error "[seed_fake] Failed to load new facilities."
      abort
    end

    logger.info "[seed_fake] Processing #{new_facilities.count} facilities."

    errors_counter = 0
    counter = 0
    new_facilities.map do |facility_hash|
      next if Facility.find_by(id: facility_hash["id"]).present?

      facility = Facility.create(facility_hash)
      if facility.persisted?
        counter += 1
        logger.info "[seed_fake] Successfully create facility (id: #{facility.id})."
      else
        errors_counter += 1
        logger.error "[seed_fake] Failed to add facility (id: #{facility.id}). Errors: #{facility.errors.full_messages.inspect}"
      end
    end

    logger.warn "[seed_fake] Failed to add #{errors_counter} facilities." if errors_counter.positive?

    logger.info "[seed_fake] Done creating facilities. #{counter} facilities created."
  end

  def load_fake_data
    json_data_location = Rails.root.join("db", "fake_data.json")
    JSON.load(json_data_location)
  end
end
