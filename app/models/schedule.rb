# frozen_string_literal: true

class Schedule
  WEEKDAY_NAMES = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday].freeze

  TimeSlot = Struct.new(:id, :from, :to, :from_time, :to_time, :from_hour, :from_min, :to_hour, :to_min, keyword_init: true)

  WeekDay = Struct.new(:week_day, :availability, :times, keyword_init: true) do
    def uses_slot2?
      slot2 = times[1]
      slot2.present? && slot2.from.present?
    end
  end

  ScheduleData = Struct.new(*WEEKDAY_NAMES, keyword_init: true) do
    def week_days
      WEEKDAY_NAMES
    end
  end

  attr_reader :facility

  def initialize(facility)
    @facility = facility
  end

  def call
    result = {}

    7.times.each do |week_day_num|
      wday = wday_from_week_day(week_day_num)
      d_name = WEEKDAY_NAMES[week_day_num]

      result[d_name] = WeekDay.new({
        week_day: d_name,
        availability: availability_for(wday),
        times: time_slots(wday)
      })
    end

    ScheduleData.new(result)
  end

  private

  def wday_from_week_day(week_day_num)
    cday = week_day_num % 7 #-> sun= 0, mon=1, ..., sat=6
    self.class.weekdays[cday]
  end

  def availability_for(wday)
    return :open if facility["open_all_day_#{wday}"]
    return :closed if facility["closed_all_day_#{wday}"]

    :set_times
  end

  def self.availabilities
    [:open, :closed, :set_times]
  end

  def time_slots(wday)
    result = []
    return result if [:open, :closed].include?(availability_for(wday))

    slot2 = time_slot2(wday)
    slot1 = time_slot1(wday)

    result << slot1
    result << slot2 if slot2.present?

    result
  end

  def time_slot1(wday)
    result = time_slot1_hash(wday)
    return result if result.blank?

    TimeSlot.new(result)
  end

  def time_slot2(wday)
    result = time_slot2_hash(wday)
    return result if result.blank?

    TimeSlot.new(result)
  end

  def time_slot1_hash(wday)
    start_time = facility["starts#{wday}_at"]
    end_time = facility["ends#{wday}_at"]

    time_slot_hash(1, start_time, end_time)
  end

  def time_slot2_hash(wday)
    return nil unless facility["second_time_#{wday}"]

    # start_time = facility["starts#{wday}_at2"].to_s(:time).split(":")
    # end_time = facility["ends#{wday}_at2"].to_s(:time).split(":")
# 
    # {
      # from_hour: start_time.first.to_i,
      # from_min: start_time.last.to_i,
      # to_hour: end_time.first.to_i,
      # to_min: end_time.last.to_i
    # }
    start_time = facility["starts#{wday}_at2"]
    end_time = facility["ends#{wday}_at2"]

    time_slot_hash(2, start_time, end_time)
  end

  def time_slot_hash(id, start_time, end_time)
    {
      id: id,
      from_hour: start_time&.hour,
      from_min: start_time&.min,
      to_hour: end_time&.hour,
      to_min: end_time&.min,
      from_time: start_time&.to_s(:time),
      to_time: end_time&.to_s(:time),
      from: start_time,
      to: end_time
    }
  end


  # def schedule_for(week_day)
    # cday = week_day % 7 #-> sun= 0, mon=1, ..., sat=6
    # # cday = DateTime.wday
    # wday = self.class.weekdays[cday]

    # availability = "set_times"
    # if self["open_all_day_#{wday}"]
      # availability = "open"
    # elsif self["closed_all_day_#{wday}"]
      # availability = "closed"
    # end

    # times = []
    # if availability == "set_times"
      # start_time = self["starts#{wday}_at"].to_s(:time).split(":")
      # end_time = self["ends#{wday}_at"].to_s(:time).split(":")
      # times << { from_hour: start_time.first,
                 # from_min: start_time.last,
                 # to_hour: end_time.first,
                 # to_min: end_time.last }
      # if self["second_time_#{wday}"]
        # start_time = self["starts#{wday}_at2"].to_s(:time).split(":")
        # end_time = self["ends#{wday}_at2"].to_s(:time).split(":")
        # times << { from_hour: start_time.first,
                   # from_min: start_time.last,
                   # to_hour: end_time.first,
                   # to_min: end_time.last }
      # end
    # end
    # { availability: availability, times: times }.with_indifferent_access
  # end

  def self.weekdays
    [:sun, :mon, :tues, :wed, :thurs, :fri, :sat]
  end
end
