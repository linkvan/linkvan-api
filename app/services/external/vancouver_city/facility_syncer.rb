# frozen_string_literal: true

# Service for syncing facility data from Vancouver City Open Data API
# Inherits from ApplicationService and handles pagination to fetch all facilities
class External::VancouverCity::FacilitySyncer < ApplicationService
  attr_reader :operation, :record, :api_key, :current, :log

  def initialize(operation:, record:, api_key:, current:, logger: Rails.logger)
    @operation = operation
    @record = record
    @current = current
    @api_key = api_key
    @log = logger

    super()
  end

  # rubocop:disable Metrics/AbcSize
  def call
    external_id = ::External::VancouverCity::FacilityMapper.external_id(record)
    log.info "Processing facility record with external_id '#{external_id}' and name '#{record['name']}' using operation '#{operation.name}'"
    builder_result = External::VancouverCity::FacilityBuilder.call(facility: current || Facility.new, record: record, api_key: api_key)
    if builder_result.failed?
      log.warn "FacilityBuilder failed for record with external_id '#{external_id}': #{builder_result.errors.join(', ')}"
      add_errors(builder_result.errors)
      return Result.new(
        data: nil,
        errors: errors
      )
    end

    built_facility = builder_result.data.facility
    result_facility = nil

    ApplicationRecord.transaction do
      case operation
      when External::SyncOperations::ExternalUpdate
        log.info "Facility with external_id '#{built_facility.external_id}' already exists, updating services"
        update_facility(built_facility)
        result_facility = built_facility
      when External::SyncOperations::InternalUpdate
        log.warn "Facility with name '#{built_facility.name}' already exists internally, adding services"
        update_facility(built_facility)
        result_facility = built_facility
      when External::SyncOperations::Create
        log.info "Creating new facility with external_id '#{built_facility.external_id}'"
        create_facility(built_facility)
        result_facility = built_facility
      else
        throw ArgumentError.new("Unsupported operation: #{operation}")
      end
    rescue ActiveRecord::RecordInvalid => e
      add_error("Failed to save facility: #{e.message}")
      result_facility = nil
    end

    Result.new(
      data: result_facility,
      errors: errors
    )
  end
  # rubocop:enable Metrics/AbcSize

  private

  def update_facility(facility)
    facility.undiscard if facility.discarded?
    facility.save!
  end

  def create_facility(facility)
    facility.save!
  end
end
