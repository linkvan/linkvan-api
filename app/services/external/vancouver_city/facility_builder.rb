# frozen_string_literal: true

# Service for building facility objects from Vancouver City Open Data API records
# Inherits from ApplicationService and handles record validation and error recovery
class External::VancouverCity::FacilityBuilder < ApplicationService
  attr_reader :facility, :record, :api_key, :mapper

  ResultData = Struct.new(:facility, keyword_init: true) do
    def blank?
      facility.nil?
    end
  end

  # Initialize the builder with required parameters
  # @param record [Hash] Single API response record
  # @param api_key [String] One of the supported API keys from External::ApiHelper
  def initialize(facility:, record:, api_key:)
    super()
    @facility = facility
    @record = record
    @api_key = api_key
    @mapper = ::External::VancouverCity::FacilityMapper.new(record)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
  # Main method that performs the facility building operation
  # @return [ApplicationService::Result] Result object with facility data and errors
  def call
    return Result.new(data: ResultData.new, errors: errors) if invalid?

    facility.assign_attributes(facility_data_from_record)

    # Build facility services
    service_builder = ::External::VancouverCity::FacilityServiceBuilder.new(facility: facility, fields: record, api_key: api_key)
    service_result = service_builder.call
    service_result.errors.each { |error| add_error(error) } unless service_result.success?

    # Build facility welcomes
    welcome_builder = ::External::VancouverCity::FacilityWelcomeBuilder.new(facility: facility, fields: record)
    welcome_result = welcome_builder.call
    welcome_result.errors.each { |error| add_error(error) } unless welcome_result.success?

    # Build facility schedules
    schedule_builder = ::External::VancouverCity::FacilityScheduleBuilder.new(facility: facility, fields: record)
    schedule_result = schedule_builder.call
    schedule_result.errors.each { |error| add_error(error) } unless schedule_result.success?

    if facility&.valid?
      Result.new(data: ResultData.new(facility: facility), errors: errors)
    else
      # rubocop:disable Style/SafeNavigationChainLength
      add_error("Facility '#{facility&.name}' is invalid: #{facility&.errors&.full_messages&.join(', ')}")
      # rubocop:enable Style/SafeNavigationChainLength
      Result.new(data: ResultData.new, errors: errors)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

  # Validates the input parameters
  # @return [Array] Array of error messages
  def validate
    @errors = []

    if record.blank?
      add_error("Record is required")
    elsif !record.is_a?(Hash)
      add_error("Record must be a Hash")
    elsif mapper.external_id(api_key).blank?
      add_error("Record is missing external_id for API key '#{api_key}'")
    elsif !valid_geometry?
      add_error("Geometry should be either Array with 2 elements or Hash with 'lat' and 'lon' keys")
    end
  end

  private

  def coords
    mapper.coordinates.presence || mapper.geo_point_2d
  end

  def valid_geometry?
    coords.present?
  end

  # Build a Facility object from an API record
  # @param record [Hash] Single API response record
  # @return [Facility, nil] Built Facility object or nil if invalid
  def facility_data_from_record
    {
      name: mapper.name,
      address: mapper.address,
      phone: mapper.phone,
      website: mapper.website,
      notes: mapper.notes,
      lat: coords.lat,
      long: coords.long,
      verified: true,
      external_id: mapper.external_id(api_key)
    }.compact
  end
end
