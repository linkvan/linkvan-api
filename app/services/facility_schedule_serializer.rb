# frozen_string_literal: true

class FacilityScheduleSerializer < ApplicationService
  def initialize(facility_schedule)
    super()

    @facility_schedule = facility_schedule
  end

  def call
    data = @facility_schedule.as_json(only: %i[availability])
    data[:times] = hashify_time_slots

    Result.new(data: data)
  end

  private

  def hashify_time_slots
    data = []
    @facility_schedule.time_slots.each do |time_slot|
      data << time_slot.as_json(only: %i[from_hour from_min to_hour to_min])
    end

    data
  end
end
