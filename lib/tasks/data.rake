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

    attention_logger = ActiveSupport::Logger.new("#{Rails.root.join("log", "import.log")}")
    logger = Rails.logger
    logger.extend(ActiveSupport::Logger.broadcast(stdout_logger))

    failed_schedules = Set.new

    # LAMBDA -> Welcomes
    valid_welcomes = FacilityWelcome.customers.keys
    process_welcomes = ->(facility, facility_hash) do
      welcome_list = facility_hash["welcomes"]
        .split
        .map(&:to_s)
        .map(&:downcase)
        .map(&:singularize)
        .map do |welcome_value|
          welcome_value == "child" ? "children" : welcome_value
        end

      welcome_list = valid_welcomes if welcome_list.include?("all")

      if (unmatched = welcome_list - valid_welcomes).present?
        logger.error "[process_welcomes] There are unmatched welcomes: #{unmatched}."
      end

      welcome_list.uniq.each do |customer|
        facility.facility_welcomes.create!(customer:)
      end
    end

    # LAMBDA -> Services
    process_services = ->(facility, facility_hash) do
      services_list = facility_hash["services"]
        .split
        .map(&:to_s)
        .map(&:downcase)
        .map do |service_value|
          service_value == "advocacy" ? "legal" : service_value
        end

      services = Service.where(key: services_list)
      if (unmatched = services_list - services.pluck(:key)).present?
        logger.error "[process_services] There are unmatched services: #{unmatched}"
      end

      services.each do |service|
        note = facility_hash["#{service.key}_note"]
        facility.facility_services.create!(service:, note:)
      end
    end

    # LAMBDA -> Schedules
    week_days = {
      sunday: 'sun',
      monday: 'mon',
      tuesday: 'tues',
      wednesday: 'wed',
      thursday: 'thurs',
      friday: 'fri',
      saturday: 'sat'
    }

    process_schedule = ->(facility, facility_hash) do
      schedules = {}
      week_days.each_pair do |wday_key, wday|
        open1  = facility_hash["starts#{wday}_at"]
        open2  = facility_hash["starts#{wday}_at2"]
        close1 = facility_hash["ends#{wday}_at"]
        close2 = facility_hash["ends#{wday}_at2"]
        open_all_day = facility_hash["open_all_day_#{wday}"]
        closed_all_day = facility_hash["closed_all_day_#{wday}"]

        slots = []
        slots << [open1, close1]
        slots << [open2, close2]

        schedules[wday_key] = { open_all_day:, closed_all_day:, slots: }
      end

      schedules.each_pair do |week_day, data|
        open_all_day = data[:open_all_day]
        closed_all_day = data[:closed_all_day]
        slots = data[:slots]

        schedule = facility.schedules.new(
          week_day:,
          open_all_day:,
          closed_all_day:
        )
        unless schedule.save
          logger.error "[seed_fake] Failed to create #{week_day} schedule for facility (id: #{facility.id}. Errors: #{schedule.errors.full_messages}"
          failed_schedules  << facility.id

          next
        end

        next if [open_all_day, closed_all_day].any?

        slots.each_with_index do |slot_data, idx|
          open, close = slot_data.map(&:to_datetime)
          time_slot = schedule.time_slots.new(
            from_hour: open.hour,
            from_min: open.minute,
            to_hour: close.hour,
            to_min: close.minute
          )
          next if time_slot.save

          logger.warn "[seed_fake] Can't create #{idx + 1}#{(idx + 1).ordinal} time slot for facility (id: #{facility.id}). Errors: #{time_slot.errors.full_messages}"
          attention_logger.warn "[import] Can't create #{idx + 1}#{(idx + 1).ordinal} time slot for facility '#{facility.name}' (id: #{facility.id}). Errors: #{time_slot.errors.full_messages}"
          failed_schedules  << facility.id
        end
      end
    end

    # Starting processing
    logger.info "[seed_fake] Loading new facilities from database."
    json_data_location = Rails.root.join("db", "fake_data.json")
    load_fake_data = JSON.load(json_data_location)
    new_facilities = load_fake_data.dig("v1", "facilities")

    if new_facilities.blank?
      logger.error "[seed_fake] Failed to load new facilities."
      abort
    end

    logger.info "[seed_fake] Processing #{new_facilities.count} facilities."

    errors_counter = 0
    counter = 0
    new_facilities.map do |facility_hash|
      if Facility.find_by(id: facility_hash["id"]).present?
        logger.error "[seed_fake] Facility id (#{facility_hash["id"]}) already exists. Skipping..."

        next
      end

      facility_attribs = facility_hash.with_indifferent_access.slice(*Facility.attribute_names)
      facility = Facility.new(facility_attribs)

      ApplicationRecord.transaction do
        unless facility.save
          logger.error "[seed_fake] Failed to create Facility (id: #{facility_attribs["id"]}). Errors: #{facility.errors.full_messages}"
          attention_logger.error "[import] Failed to create Facility '#{facility.name}' (id: #{facility_attribs["id"]}). Errors: #{facility.errors.full_messages}"

          next
        end

        process_welcomes.call(facility, facility_hash)
        process_services.call(facility, facility_hash)
        process_schedule.call(facility, facility_hash)
      end

      if facility.persisted?
        counter += 1
        logger.info "[seed_fake] Successfully create facility (id: #{facility.id})."
      end
    end

    logger.warn "[seed_fake] Failed to add #{errors_counter} facilities." if errors_counter.positive?
    logger.warn "[seed_fake] These #{failed_schedules.count} facilities schedules need review. IDs: #{failed_schedules}" if failed_schedules.present?

    logger.info "[seed_fake] Done creating facilities. #{counter} facilities created."
  end
end
