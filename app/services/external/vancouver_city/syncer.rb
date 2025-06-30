# frozen_string_literal: true

module External::VancouverCity
  # Service for syncing facility data from Vancouver City Open Data API
  # Inherits from ApplicationService and handles pagination to fetch all facilities
  class Syncer < ApplicationService
    attr_reader :api_key, :api_client

    LIMIT = 50 # Maximum records per request allowed by the API

    # Initialize the syncer with required parameters
    # @param api_key [String] One of the supported API keys from External::ApiHelper
    # @param api_client [VancouverApiClient] The API client instance
    def initialize(api_key:, api_client:)
      super()
      @api_key = api_key
      @api_client = api_client
    end

    # Main method that performs the sync operation
    # @return [ApplicationService::Result] Result object with data and errors
    def call
      return Result.new(data: nil, errors: errors) if invalid?

      facilities = []
      offset = 0

      loop do
        Rails.logger.info "Fetching facilities from #{api_key} API (offset: #{offset}, limit: #{LIMIT})"

        begin
          response = api_client.get_dataset_records(api_key, limit: LIMIT, offset: offset)
          records = response.body.dig('results') || []

          break if records.empty?

          # Process each record and build Facility objects
          batch_facilities = process_records(records)
          facilities.concat(batch_facilities)

          # If we got fewer records than the limit, we've reached the end
          break if records.size < LIMIT

          offset += LIMIT
        rescue VancouverApiError => e
          add_error("API request failed: #{e.message}")
          break
        rescue StandardError => e
          add_error("Unexpected error during sync: #{e.message}")
          break
        end
      end

      Rails.logger.info "Successfully processed #{facilities.size} facilities from #{api_key} API"

      Result.new(
        data: {
          facilities: facilities,
          total_count: facilities.size,
          api_key: api_key
        },
        errors: errors
      )
    end

    # Validates the input parameters
    # @return [Array] Array of error messages
    def validate
      @errors = []

      unless External::ApiHelper.supported_api?(api_key)
        add_error("Unsupported API: #{api_key}")
      end

      if api_client.nil?
        add_error("API client is required")
      elsif !api_client.is_a?(VancouverApiClient)
        add_error("API client must be an instance of VancouverApiClient")
      end

      errors
    end

    private

    # Process API records and convert them to Facility objects
    # @param records [Array<Hash>] Array of API response records
    # @return [Array<Facility>] Array of built Facility objects
    def process_records(records)
      facilities = []

      records.each do |record|
        builder_result = FacilityBuilder.call(record: record, api_key: api_key)
        
        if builder_result.success?
          facilities << builder_result.data[:facility]
        else
          # Add builder errors to syncer errors
          add_errors(builder_result.errors)
        end
      end

      facilities
    end
  end
end
