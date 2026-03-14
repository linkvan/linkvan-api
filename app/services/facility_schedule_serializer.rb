# frozen_string_literal: true

class FacilityScheduleSerializer < ApplicationService
  def initialize(facility_schedule)
    super()

    @facility_schedule = facility_schedule
  end

  def call
    data = { availability: @facility_schedule.availability }
    data[:times] = hashify_time_slots

    Result.new(data: data)
  end

  private

  def hashify_time_slots
    @facility_schedule.time_slots.map do |time_slot|
      time_slot.as_json(only: %i[from_hour from_min to_hour to_min])
    end
  end
end
