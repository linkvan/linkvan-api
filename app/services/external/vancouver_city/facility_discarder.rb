# frozen_string_literal: true

class External::VancouverCity::FacilityDiscarder < ApplicationService
  attr_reader :facility

  def initialize(facility)
    @facility = facility
    super()
  end

  def call
    # Return early if the facility is already discarded
    return build_result if facility.discarded?

    facility.discard_reason = :sync_removed
    unless facility.discard
      # discard failed, collect errors
      add_errors(facility.errors.full_messages)
    end

    build_result
  end

  private

  # Builds the result object for this discard operation
  def build_result
    ::External::VancouverCity::Syncer::SyncResultDataEntry.new(
      operation: External::SyncOperations.discard,
      facility: facility,
      errors: errors
    )
  end
end
