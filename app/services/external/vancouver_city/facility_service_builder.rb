# frozen_string_literal: true

module External::VancouverCity
  # Service for building facility service associations for Vancouver City facilities
  # Associates facilities with services based on API key
  class FacilityServiceBuilder < ApplicationService
    attr_reader :facility, :fields, :api_key

    # Initialize the builder with required parameters
    # @param facility [Facility] The facility object to add services to
    # @param fields [Hash] API record fields (currently unused but kept for future extensibility)
    # @param api_key [String] The API key used to find the corresponding service
    def initialize(facility:, fields:, api_key:)
      super()
      @facility = facility
      @fields = fields
      @api_key = api_key
    end

    # Main method that performs the service association building operation
    # @return [ApplicationService::Result] Result object with success status and errors
    def call
      return Result.new(data: nil, errors: errors) if invalid?

      begin
        add_facility_services
        Result.new(data: { services_count: facility.facility_services.size }, errors: errors)
      rescue StandardError => e
        add_error("Failed to build facility services: #{e.message}")
        Result.new(data: nil, errors: errors)
      end
    end

    # Validates the input parameters
    # @return [Array] Array of error messages
    def validate
      @errors = []

      if facility.blank?
        add_error("Facility is required")
      elsif !facility.is_a?(Facility)
        add_error("Facility must be a Facility object")
      end

      if fields.blank?
        add_error("Fields are required")
      elsif !fields.is_a?(Hash)
        add_error("Fields must be a Hash")
      end

      if api_key.blank?
        add_error("API key is required")
      elsif !External::ApiHelper.supported_api?(api_key)
        add_error("Unsupported API key: #{api_key}")
      end

      errors
    end

    private

    # Add services to facility based on API key
    def add_facility_services
      service_key = External::ApiHelper.service_key_for(api_key)
      return if service_key.nil?

      service = Service.find_by(key: service_key)
      return if service.blank?
      
      # Build FacilityService association without saving
      facility.facility_services.build(service: service)
    end
  end
end
