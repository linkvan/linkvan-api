# frozen_string_literal: true

class FacilitySerializer < ApplicationService
  include Serializable

  NON_COMPLETE_ATTRIBUTES = %i[id name lat long phone updated_at].freeze

  def initialize(facility, complete: true)
    super()

    @facility = facility
    @complete = complete
  end

  def call
    data = if @complete.present?
      hashify(@facility, Facility.attribute_names)
    else
      hashify(@facility, NON_COMPLETE_ATTRIBUTES)
    end

    data[:services] = hashify_services
    data[:zone] = hashify_zone(@facility.zone)
    data[:schedule] = hashify_schedules

    Result.new(data: data.symbolize_keys)
  end

  private

  def hashify_services
    data = []
    @facility.facility_services.each do |facility_service|
      data << {
        name: facility_service.name,
        note: facility_service.note
      }
    end

    data
  end

  def hashify_zone(zone)
    zone.as_json(only: %i[id name])&.symbolize_keys
  end

  def hashify_schedules
    data = []
    @facility.schedules.each do |schedule|
      data << hashify_facility_schedule(schedule)
    end

    data
  end

  def hashify_facility_schedule(schedule)
    result = FacilityScheduleSerializer.call(schedule)

    result_key = "schedule_#{schedule.week_day}".to_sym

    { result_key => result.data }
  end
end
