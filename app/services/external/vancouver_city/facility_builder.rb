# frozen_string_literal: true

module External::VancouverCity
  # Service for building facility objects from Vancouver City Open Data API records
  # Inherits from ApplicationService and handles record validation and error recovery
  class FacilityBuilder < ApplicationService
    attr_reader :record, :api_key

    ResultData = Struct.new(:facility, keyword_init: true) do
      def blank?
        facility.nil?
      end
    end

    # Initialize the builder with required parameters
    # @param record [Hash] Single API response record
    # @param api_key [String] One of the supported API keys from External::ApiHelper
    def initialize(record:, api_key:)
      super()
      @record = record
      @api_key = api_key
    end

    # Main method that performs the facility building operation
    # @return [ApplicationService::Result] Result object with facility data and errors
    def call
      return Result.new(data: ResultData.new, errors: errors) if invalid?

      begin
        facility = build_facility_from_record

        # Build facility services
        service_builder = FacilityServiceBuilder.new(facility: facility, fields: record, api_key: api_key)
        service_result = service_builder.call
        unless service_result.success?
          service_result.errors.each { |error| add_error(error) }
        end

        # Build facility welcomes
        welcome_builder = FacilityWelcomeBuilder.new(facility: facility, fields: record)
        welcome_result = welcome_builder.call
        unless welcome_result.success?
          welcome_result.errors.each { |error| add_error(error) }
        end

        # Build facility schedules
        schedule_builder = FacilityScheduleBuilder.new(facility: facility, fields: record)
        schedule_result = schedule_builder.call
        unless schedule_result.success?
          schedule_result.errors.each { |error| add_error(error) }
        end

        if facility&.valid?
          Result.new(data: ResultData.new(facility: facility), errors: errors)
        else
          add_error("Facility #{facility&.name} is invalid: #{facility&.errors&.full_messages&.join(', ')}")
          Result.new(data: ResultData.new, errors: errors)
        end
      rescue StandardError => e
        add_error("Failed to build facility from record: #{e.message}")
        Rails.logger.warn "Failed to build facility from record: #{e.message}"
        Rails.logger.warn "Record data: #{record.inspect}"
        Result.new(data: ResultData.new, errors: errors)
      end
    end

    # Validates the input parameters
    # @return [Array] Array of error messages
    def validate
      @errors = []

      if record.blank?
        add_error("Record is required")
      elsif !record.is_a?(Hash)
        add_error("Record must be a Hash")
      elsif !valid_geometry?
        add_error("Geometry should be either Array with 2 elements or Hash with 'lat' and 'lon' keys")
      end
    end

    private

    def valid_geometry?
      coordinates.present? || geo_point_2d.present?
    end

    # Build a Facility object from an API record
    # @param record [Hash] Single API response record
    # @return [Facility, nil] Built Facility object or nil if invalid
    def build_facility_from_record
      coords = coordinates.presence || geo_point_2d

      facility_data = {
        name: extract_name(record),
        address: extract_address(record),
        phone: extract_phone(record),
        website: extract_website(record),
        notes: extract_notes(record),
        lat: coords[:lat],
        long: coords[:long],
        verified: true,
        external_id: record['mapid'] || "#{api_key}-unknown-id",
      }.compact

      Facility.new(facility_data)
    end

    # Extract facility name from fields
    # @param fields [Hash] API record fields
    # @return [String, nil] Facility name
    def extract_name(fields)
      name = fields['name']
      return nil unless name
      
      # Replace special characters with whitespace and clean up
      name.gsub(/\\n/, ' ').tr("\n", ' ').gsub(/\s+/, ' ').strip.presence
    end

    # Extract address from fields
    # @param fields [Hash] API record fields
    # @return [String, nil] Facility address
    def extract_address(fields)
      # For drinking fountains, use the location field and geo_local_area
      location = fields['location']
      area = fields['geo_local_area']
      
      [location, area].compact.join(', ').presence
    end

    # Extract phone number from fields
    # @param fields [Hash] API record fields
    # @return [String, nil] Phone number
    def extract_phone(fields)
      fields['phone'] || fields['phone_number'] || fields['contact_phone']
    end

    # Extract website from fields
    # @param fields [Hash] API record fields
    # @return [String, nil] Website URL
    def extract_website(fields)
      fields['website'] || fields['url'] || fields['web_site']
    end

    # Extract notes/description from fields
    # @param fields [Hash] API record fields
    # @return [String, nil] Notes or description
    def extract_notes(fields)
      notes_parts = []
      
      # Include maintainer info
      notes_parts << "Maintained by: #{fields['maintainer']}" if fields['maintainer'].present?
      
      # Include operation info
      notes_parts << "Operation: #{fields['in_operation']}" if fields['in_operation'].present?
      
      # Include pet friendly info
      notes_parts << "Pet friendly: #{fields['pet_friendly']}" if fields['pet_friendly'].present?
      
      notes_parts.join('. ').presence
    end

    # Extract coordinates from geometry
    # @return [Hash] Hash with :lat and :long keys
    def coordinates
      coords = record.dig('geom', 'geometry', 'coordinates').presence || []
      return {} unless coords.size == 2

      # GeoJSON coordinates are [longitude, latitude]
      { lat: coords[1], long: coords[0] }
    end

    # Extract coordinates from geo_point_2d field
    # @return [Hash] Hash with :lat and :long keys
    def geo_point_2d
      geo_point = record.dig('geo_point_2d').presence || {}
      return {} unless geo_point.is_a?(Hash)
      return {} unless geo_point.key?('lat') && geo_point.key?('lon')

      { lat: geo_point['lat'], long: geo_point['lon'] }
    end
  end
end
