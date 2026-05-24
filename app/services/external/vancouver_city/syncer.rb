# frozen_string_literal: true

# Service for syncing facility data from Vancouver City Open Data API
# Inherits from ApplicationService and handles pagination to fetch all facilities
class External::VancouverCity::Syncer < ApplicationService
  attr_reader :api_key, :api_client, :full_sync

  PAGE_SIZE = 50 # Maximum records per request allowed by the API
  SyncResultDataEntry = Struct.new(:operation, :facility, :errors, keyword_init: true) do
    def success?
      errors.blank?
    end

    def failed?
      errors.present?
    end

    # Returns a human-readable error message for this sync result entry
    def error_messages
      return [] if success?
      return "#{operation.name} failed: #{errors.join(', ')}" if facility.blank?

      "#{operation.name} failed for facility '#{facility.name}': #{errors.join(', ')}"
    end
  end

  SyncResult = Struct.new(:result, keyword_init: true) do
    delegate :failed?, :success?, :data, :errors, to: :result

    def partial_failed?
      result_errors.flatten.empty? && entry_error_messages.flatten.any?
    end

    def error_messages
      (result_errors + entry_error_messages).flatten.compact.uniq
    end

    private

    def result_errors
      result.errors.presence || []
    end

    def entry_error_messages
      data.presence&.map(&:error_messages) || []
    end
  end

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
    return build_result([], errors) if invalid?

    Rails.logger.info "Starting sync for #{api_key} API (full_sync: #{full_sync})"

    sync_results = sync_facilities_from_api
    synced_external_ids = sync_results
      .select(&:success?)
      .map { |result| result.facility.external_id }
    success_count = synced_external_ids.size
    failed_count = sync_results.size - success_count

    discard_results = discard_missing_facilities(synced_external_ids)
    discard_success_count = discard_results.count { |result| result.errors.blank? }
    discard_failed_count = discard_results.size - discard_success_count

    Rails.logger.info "Finished sync for #{api_key} API: #{success_count} succeeded, #{failed_count} failed, #{discard_success_count} discarded, #{discard_failed_count} failed to discard"

    build_result(sync_results + discard_results, errors)
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

  def build_result(result_data, result_errors)
    SyncResult.new(
      result: Result.new(
        data: result_data,
        errors: result_errors
      )
    )
  end

  # Syncs facilities from the API with pagination
  # @return [Array] Array containing facilities, synced_external_ids, created_count, updated_count
  def sync_facilities_from_api
    sync_results = []
    offset = 0

    loop do
      Rails.logger.info "Fetching facilities from #{api_key} API (offset: #{offset}, limit: #{PAGE_SIZE})"

      begin
        response = api_client.get_dataset_records(api_key, limit: PAGE_SIZE, offset: offset)
        records = response.body["results"] || []

        break if records.empty?

        # Process each record and build Facility objects
        batch_results = process_records_with_operations(records)
        sync_results += batch_results

        # If we got fewer records than the limit, we've reached the end
        break if records.size < PAGE_SIZE

        offset += PAGE_SIZE
      rescue External::VancouverCity::VancouverApiError => e
        sync_results << SyncResultDataEntry.new(
          operation: External::SyncOperations.api_call,
          facility: nil,
          errors: ["API request failed: #{e.message}"]
        )
        break
      rescue StandardError => e
        sync_results << SyncResultDataEntry.new(
          operation: External::SyncOperations.unexpected_error,
          facility: nil,
          errors: ["Unexpected error during sync; #{e.class}: #{e.message}"]
        )
        # raise
        break
      end
    end

    sync_results
  end

  # Process API records and return ResultData objects with operations
  # @param records [Array<Hash>] Array of API response records
  # @return [Array<External::VancouverCity::FacilitySyncer::ResultData>] Array of result data objects
  def process_records_with_operations(records)
    external_ids = records.filter_map { |record| ::External::VancouverCity::FacilityMapper.external_id(record) }
    names = records.filter_map { |record| ::External::VancouverCity::FacilityMapper.name(record) }
    existing_facilities = Facility.with_associations
                                  .with_discarded
                                  .where(external_id: external_ids)
                                  .to_a
    existing_facilities_by_name = Facility.with_associations
                                         .with_discarded
                                         .where(name: names)
                                         .to_a

    records.map do |record|
      process_single_record(record.with_indifferent_access, existing_facilities, existing_facilities_by_name)
    end
  end

  def process_single_record(record, existing_facilities, existing_facilities_by_name)
    external_id = ::External::VancouverCity::FacilityMapper.external_id(record)
    if external_id.nil?
      return SyncResultDataEntry.new(
        operation: External::SyncOperations.unknown,
        facility: nil,
        errors: ["Missing external_id for record with name '#{record['name']}'"]
      )
    end

    current_facility = existing_facilities.find { |f| f.external_id == external_id } ||
                       existing_facilities_by_name.find { |f| f.name == ::External::VancouverCity::FacilityMapper.name(record) }
    operation = if current_facility.blank?
                  External::SyncOperations.create
                elsif current_facility.external?
                  External::SyncOperations.external_update
                else
                  External::SyncOperations.internal_update
                end

    syncer_result = External::VancouverCity::FacilitySyncer.call(
      operation: operation,
      record: record,
      current: current_facility,
      api_key: api_key,
      logger: Rails.logger
    )
    SyncResultDataEntry.new(
      operation: operation,
      facility: syncer_result.data,
      errors: syncer_result.errors
    )
  end

  # Discard facilities that were not in the API response (full sync only)
  # @param synced_external_ids [Array<String>] Array of external_ids that were in the response
  # @return [Integer] Number of facilities discarded
  def discard_missing_facilities(synced_external_ids)
    return [] unless full_sync

    results = []
    External::SyncOperations.discard

    # Only discard facilities that are currently kept
    #   (not already discarded with deleted_at set)
    missing_facilities = Facility.external.kept
      .where.not(external_id: synced_external_ids)

    missing_facilities.find_each do |facility|
      results << External::VancouverCity::FacilityDiscarder.call(facility)
    end

    results
  end
end
