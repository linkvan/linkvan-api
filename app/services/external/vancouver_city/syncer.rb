# frozen_string_literal: true

# Service for syncing facility data from Vancouver City Open Data API
# Inherits from ApplicationService and handles pagination to fetch all facilities
class External::VancouverCity::Syncer < ApplicationService
  attr_reader :api_key, :api_client, :full_sync

  PAGE_SIZE = 50 # Maximum records per request allowed by the API

  # Initialize the syncer with required parameters
  # @param api_key [String] One of the supported API keys from External::ApiHelper
  # @param api_client [VancouverApiClient] The API client instance
  # @param full_sync [Boolean] Whether to perform a full sync (discard missing facilities)
  def initialize(api_key:, api_client:, full_sync: true)
    super()
    @api_key = api_key
    @api_client = api_client
    @full_sync = full_sync
  end

  # Main method that performs the sync operation
  # @return [ApplicationService::Result] Result object with data and errors
  def call
    return Result.new(data: nil, errors: errors) if invalid?

    facilities, synced_external_ids, created_count, updated_count = sync_facilities_from_api

    discarded_count = discard_missing_facilities(synced_external_ids)

    Rails.logger.info "Successfully processed #{facilities.size} facilities from #{api_key} API"

    build_result(facilities, created_count, updated_count, discarded_count)
  end

  # Validates the input parameters
  # @return [Array] Array of error messages
  def validate
    @errors = []

    add_error("Unsupported API: #{api_key}") unless External::ApiHelper.supported_api?(api_key)

    if api_client.nil?
      add_error("API client is required")
    elsif !api_client.is_a?(External::VancouverCity::VancouverApiClient)
      add_error("API client must be an instance of VancouverApiClient")
    end

    errors
  end

  private

  # Syncs facilities from the API with pagination
  # @return [Array] Array containing facilities, synced_external_ids, created_count, updated_count
  def sync_facilities_from_api
    facilities = []
    synced_external_ids = []
    created_count = 0
    updated_count = 0
    offset = 0

    loop do
      Rails.logger.info "Fetching facilities from #{api_key} API (offset: #{offset}, limit: #{PAGE_SIZE})"

      begin
        response = api_client.get_dataset_records(api_key, limit: PAGE_SIZE, offset: offset)
        records = response.body["results"] || []

        break if records.empty?

        # Process each record and build Facility objects
        batch_results = process_records_with_operations(records)
        batch_results.each do |result|
          facilities << result.facility
          synced_external_ids << result.facility.external_id if result.facility.respond_to?(:external_id)
          case result.operation
          when :create
            created_count += 1
          when :external_update, :internal_update
            updated_count += 1
          end
        end

        # If we got fewer records than the limit, we've reached the end
        break if records.size < PAGE_SIZE

        offset += PAGE_SIZE
      rescue External::VancouverCity::VancouverApiError => e
        add_error("API request failed: #{e.message}")
        break
      rescue StandardError => e
        add_error("Unexpected error during sync: #{e.message}")
        break
      end
    end

    [facilities, synced_external_ids, created_count, updated_count]
  end

  # Builds the result object for the sync operation
  # @param facilities [Array<Facility>] Array of synced facilities
  # @param created_count [Integer] Number of created facilities
  # @param updated_count [Integer] Number of updated facilities
  # @param discarded_count [Integer] Number of discarded facilities
  # @return [ApplicationService::Result] Result object with data and errors
  def build_result(facilities, created_count, updated_count, discarded_count)
    Result.new(
      data: {
        facilities: facilities,
        total_count: facilities.size,
        created_count: created_count,
        updated_count: updated_count,
        deleted_count: discarded_count,
        api_key: api_key
      },
      errors: errors
    )
  end

  # # Process API records and convert them to Facility objects
  # # @param records [Array<Hash>] Array of API response records
  # # @return [Array<Facility>] Array of built Facility objects
  # def process_records(records)
  #   facilities = []

  #   records.each do |record|
  #     syncer_result = External::VancouverCity::FacilitySyncer.call(record: record, api_key: api_key)

  #     if syncer_result.success?
  #       facilities << syncer_result.data[:facility]
  #     else
  #       add_errors(syncer_result.errors)
  #     end
  #   end

  #   facilities
  # end

  # Process API records and return ResultData objects with operations
  # @param records [Array<Hash>] Array of API response records
  # @return [Array<External::VancouverCity::FacilitySyncer::ResultData>] Array of result data objects
  def process_records_with_operations(records)
    results = []

    external_ids = records.pluck("mapid").compact
    existing_facilities = Facility.with_associations
                                  .with_discarded
                                  .where(external_id: external_ids)
                                  .to_a
    # existing_facility = Facility.with_discarded
    #                             .find_by(external_id: built_facility.external_id)
    # Need to also load facilities that match by name in case external_id is missing or changed, but prefer matches by external_id when available
    # Facility.with_discarded
    #         .where(name: built_facility.name)
    #         .order(Arel.sql("external_id IS NULL DESC, external_id"))
    #         .first

    records.each do |record|
      current_facility = existing_facilities.find { |f| f.external_id == record["mapid"] }
      syncer_result = External::VancouverCity::FacilitySyncer.call(record: record, current: current_facility, api_key: api_key)

      if syncer_result.success?
        data = syncer_result.data
        # Support both ResultData objects and legacy hash format
        results << if data.respond_to?(:operation)
                     data
                   else
                     # Legacy hash format: { facility: ... }
                     External::VancouverCity::FacilitySyncer::ResultData.new(
                       operation: nil,
                       facility: data[:facility]
                     )
                   end
      else
        add_errors(syncer_result.errors)
      end
    end

    results
  end

  # Discard facilities that were not in the API response (full sync only)
  # @param synced_external_ids [Array<String>] Array of external_ids that were in the response
  # @return [Integer] Number of facilities discarded
  def discard_missing_facilities(synced_external_ids)
    return 0 unless full_sync

    # Only discard facilities that:
    # 1. Are currently kept (not already discarded with deleted_at set)
    # 2. Have not been previously marked as sync_removed
    missing_facilities = Facility.external.kept
      .where.not(external_id: synced_external_ids)
      .where("discard_reason IS NULL OR discard_reason != ?", "sync_removed")

    count = 0
    missing_facilities.find_each do |facility|
      facility.discard_reason = :sync_removed
      facility.discard!
      count += 1
    end

    count
  end
end
