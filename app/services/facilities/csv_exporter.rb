# frozen_string_literal: true

require "csv"

class Facilities::CsvExporter < ApplicationService
  WEEKDAYS = %w[sunday monday tuesday wednesday thursday friday saturday].freeze

  HEADERS = [
    "ID",
    "Name",
    "Status",
    "Address",
    "Phone",
    "Website",
    "Lat",
    "Long",
    "Zone",
    "Services",
    "Welcomes",
    "Notes",
    "External ID",
    "Created At",
    "Updated At"
  ] + WEEKDAYS.map(&:titleize)

  def initialize(facilities)
    super()

    @facilities = facilities
  end

  def call
    csv_string = CSV.generate(headers: true) do |csv|
      csv << HEADERS

      @facilities.each do |facility|
        csv << build_row(facility)
      end
    end

    success(csv_string)
  end

  private

  def build_row(facility)
    [
      facility.id,
      facility.name,
      facility.status.to_s.titleize,
      facility.address,
      facility.phone,
      facility.website,
      facility.lat,
      facility.long,
      facility.zone&.name,
      format_services(facility),
      format_welcomes(facility),
      facility.notes,
      facility.external_id,
      facility.created_at&.iso8601,
      facility.updated_at&.iso8601
    ] + format_schedules(facility)
  end

  def format_services(facility)
    facility.facility_services.map do |fs|
      if fs.note.present?
        "#{fs.service.name} (#{fs.note})"
      else
        fs.service.name
      end
    end.join(", ")
  end

  def format_welcomes(facility)
    facility.facility_welcomes.map(&:name).join(", ")
  end

  def format_schedules(facility)
    schedules_by_day = facility.schedules.index_by(&:week_day)

    WEEKDAYS.map do |weekday|
      schedule = schedules_by_day[weekday]
      format_schedule(schedule)
    end
  end

  def format_schedule(schedule)
    return "Closed" if schedule.nil? || schedule.closed_all_day?
    return "Open All Day" if schedule.open_all_day?

    schedule.time_slots.map do |ts|
      "#{ts.start_time_for_displaying} - #{ts.end_time_for_displaying}"
    end.join(", ")
  end
end
