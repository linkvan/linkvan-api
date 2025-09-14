# frozen_string_literal: true

module External::VancouverCity
  # Service for building facility schedule objects for Vancouver City facilities
  # Creates open-all-day schedules for all weekdays as per business requirements
  class FacilityScheduleBuilder < ApplicationService
    attr_reader :facility, :fields

    # Initialize the builder with required parameters
    # @param facility [Facility] The facility object to add schedules to
    # @param fields [Hash] API record fields (currently unused but kept for future extensibility)
    def initialize(facility:, fields:)
      super()
      @facility = facility
      @fields = fields
    end

    # Main method that performs the schedule building operation
    # @return [ApplicationService::Result] Result object with success status and errors
    def call
      return Result.new(data: nil, errors: errors) if invalid?

      begin
        add_facility_schedules
        Result.new(data: { schedules_count: facility.schedules.size }, errors: errors)
      rescue StandardError => e
        add_error("Failed to build facility schedules: #{e.message}")
        Result.new(data: nil, errors: errors)
      end
    end

    # Validates the input parameters
    # @return [Array] Array of error messages
    def validate
      @errors = []

      if facility.nil?
        add_error("Facility is required")
      elsif !facility.is_a?(Facility)
        add_error("Facility must be a Facility object")
      end

      if fields.nil?
        add_error("Fields are required")
      elsif !fields.is_a?(Hash)
        add_error("Fields must be a Hash")
      end

      errors
    end

    private

    # Add schedules to facility based on business requirements
    # Creates open-all-day schedules for all weekdays
    def add_facility_schedules
      FacilitySchedule.week_days.keys.each do |day|
        facility.schedules.build(
          week_day: day,
          closed_all_day: false,
          open_all_day: true
        )
      end
    end
  end
end
