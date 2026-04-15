# frozen_string_literal: true

# Service for syncing facility data from Vancouver City Open Data API
# Inherits from ApplicationService and handles pagination to fetch all facilities
class External::VancouverCity::FacilitySyncer < ApplicationService
  attr_reader :record, :api_key, :current, :logger

  ResultData = Struct.new(:operation, :facility, keyword_init: true) do
    delegate :present?, :blank?, to: :facility
  end

  def initialize(record:, api_key:, current:, logger: Rails.logger)
    @record = record
    @current = current
    @api_key = api_key
    @logger = logger

    super()
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def call
    builder_result = External::VancouverCity::FacilityBuilder.call(record: record, api_key: api_key)
    if builder_result.failed?
      add_errors(builder_result.errors)
      return Result.new(
        data: ResultData.new(operation: nil, facility: nil),
        errors: errors
      )
    end

    built_facility = builder_result.data[:facility]
    existing_facility = current
    operation = if existing_facility.blank?
                  :create
                elsif existing_facility.external?
                  :external_update
                else
                  :internal_update
                end
    result_facility = nil

    ApplicationRecord.transaction do
      case operation
      when :external_update
        logger.info "Facility with external_id '#{existing_facility.external_id}' already exists, updating services"
        update_external_facility(existing_facility, built_facility)
        result_facility = existing_facility
      when :internal_update
        logger.warn "Facility with name '#{existing_facility.name}' already exists internally, adding services"
        update_internal_facility(existing_facility, built_facility)
        result_facility = existing_facility
      when :create
        logger.info "Creating new facility with external_id '#{built_facility.external_id}'"
        if built_facility.invalid?
          add_errors(built_facility.errors)
          result_facility = nil
        else
          built_facility.save!
          result_facility = built_facility
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      add_error("Failed to save facility: #{e.message}")
      result_facility = nil
    rescue StandardError => e
      add_error("Unexpected error during facility sync: #{e.message}")
      result_facility = nil
    end

    Result.new(
      data: ResultData.new(operation: operation, facility: result_facility),
      errors: errors
    )
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def update_internal_facility(internal_facility, built_facility)
    internal_facility.undiscard if internal_facility.discarded?

    add_missing_services(internal_facility, built_facility)
  end

  def update_external_facility(external_facility, built_facility)
    external_facility.undiscard if external_facility.discarded?

    add_missing_services(external_facility, built_facility)
    external_facility.update!(built_facility.attributes.slice("name", "address", "lat", "long", "verified"))
  end

  def add_missing_services(existing_facility, built_facility)
    built_services = built_facility.facility_services.map(&:service).uniq
    existing_services = existing_facility.facility_services.map(&:service).uniq
    new_services = built_services - existing_services

    new_services.each do |service|
      existing_facility.facility_services.create!(service: service)
    end
  end
end
