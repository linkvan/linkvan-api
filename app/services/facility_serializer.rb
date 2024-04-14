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
      hashify(@facility, facility_attributes)
    else
      hashify(@facility, NON_COMPLETE_ATTRIBUTES)
    end

    data[:website] = @facility.website_url
    data[:welcomes] = hashify_welcomes
    data[:services] = hashify_services
    data[:zone] = hashify_zone(@facility.zone)
    data[:schedule] = hashify_schedules

    Result.new(data: data.symbolize_keys)
  end

  private

  def facility_attributes
    Facility.attribute_names - %w[website]
  end

  def hashify_services
    data = []
    @facility.facility_services.each do |facility_service|
      data << {
        key: facility_service.key,
        name: facility_service.name,
        note: facility_service.note
      }
    end

    data
  end

  def hashify_welcomes
    data = []
    @facility.facility_welcomes.each do |facility_welcome|
      data << {
        key: facility_welcome.customer,
        name: facility_welcome.name
      }
    end
    data
  end

  def hashify_zone(zone)
    zone.as_json(only: %i[id name])&.symbolize_keys
  end

  def hashify_schedules
    data = build_closed_all_day_schedule_data

    @facility.schedules.each do |schedule|
      result_key = schedule_key_for(schedule.week_day)
      data[result_key] = hashify_facility_schedule(schedule)
    end

    data
  end

  def hashify_facility_schedule(schedule)
    result = FacilityScheduleSerializer.call(schedule)

    result.data
  end

  def schedule_key_for(week_day)
    "schedule_#{week_day}".to_sym
  end

  def build_closed_all_day_schedule_data
    result = {}
    # Initialize all keys to make sure the schedule always contain them
    FacilitySchedule.week_days.each_key.each do |week_day|
      result[schedule_key_for(week_day)] = hashify_facility_schedule(
        FacilitySchedule.new(closed_all_day: true)
      )
    end
    result
  end
end
