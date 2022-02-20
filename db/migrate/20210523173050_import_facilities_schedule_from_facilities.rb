class ImportFacilitiesScheduleFromFacilities < ActiveRecord::Migration[6.1]
  WEEKDAY_NAMES = { sun: :sunday,
                    mon: :monday,
                    tues: :tuesday,
                    wed: :wednesday,
                    thurs: :thursday,
                    fri: :friday,
                    sat: :saturday }.freeze

  def up
    Facility.all.find_each do |facility|
      say_with_time "Facility: #{facility.id}" do
        create_schedules(facility)
      end
    end
  end

  def down
    FacilitySchedule.all.each { |facility| facility.destroy! }
  end

  def create_schedules(facility)
    # weekday_names = Date::DAYNAMES.map(&:downcase).map(&:to_sym)
    # weekday_names_columns = [:sun, :mon, :tues, :wed, :thurs, :fri, :sat]

    # weekday_names_columns.each do |abbr_weekday|
    data = schedule_columns_from(facility)
    data.each_pair do |abbr_weekday, weekday_data|
      say WEEKDAY_NAMES[abbr_weekday]

      slot1 = weekday_data[:slot1]
      slot2 = weekday_data[:slot2]

      open_all_day = weekday_data[:open_all_day] 
      closed_all_day = weekday_data[:closed_all_day]

      schedule = FacilitySchedule.create({
        facility: facility,
        week_day: WEEKDAY_NAMES[abbr_weekday],
        open_all_day: open_all_day || false,
        closed_all_day: closed_all_day || false
      })

      next if open_all_day || closed_all_day

      # Slot 1
      if slot1.present?
        FacilityTimeSlot.create(
          facility_schedule: schedule,
          from_hour: slot1[:from].hour,
          from_min: slot1[:from].min,
          to_hour: slot1[:to].hour,
          to_min: slot1[:to].min
        )
      end

      # Slot 2
      if slot2.present?
        FacilityTimeSlot.create(
          facility_schedule: schedule,
          from_hour: slot2[:from].hour,
          from_min: slot2[:from].min,
          to_hour: slot2[:to].hour,
          to_min: slot2[:to].min
        )
      end
    end
  end

  def schedule_columns_from(facility)
    result = {}

    WEEKDAY_NAMES.each_key do |abbr_weekday|
      result[abbr_weekday] = {
        open_all_day: facility["open_all_day_#{abbr_weekday}"],
        closed_all_day: facility["closed_all_day_#{abbr_weekday}"],
        slot1: slot1(facility, abbr_weekday),
        slot2: slot2(facility, abbr_weekday),
      }
    end

    result
  end

  def slot1(facility, wday)
    from = facility["starts#{wday}_at"]
    to = facility["ends#{wday}_at"]
    return nil if from.blank? || to.blank?

    {
      from: from,
      to: to
    }
  end

  def slot2(facility, wday)
    return nil unless facility["second_time_#{wday}"]

    from = facility["starts#{wday}_at2"]
    to = facility["ends#{wday}_at2"]
    return nil if from.blank? || to.blank?

    {
      from: from,
      to: to
    }
  end
end
