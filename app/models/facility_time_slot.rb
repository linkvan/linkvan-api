# frozen_string_literal: true

class FacilityTimeSlot < ApplicationRecord
  belongs_to :facility_schedule
  has_one :facility, through: :facility_schedule

  validates :from_hour, :to_hour, presence: true,
                                  numericality: { only_integer: true,
                                                  greater_than_or_equal_to: 0,
                                                  less_than: 24 }
  validates :from_min, :to_min, presence: true,
                                numericality: { only_integer: true,
                                                greater_than_or_equal_to: 0,
                                                less_than: 60 }

  validate :validate_non_overlaping_time_slot_range

  delegate :week_day, to: :facility_schedule, allow_nil: true

  def start_time
    start_time_string.to_time
  end

  def end_time
    end_time_string.to_time
  end

  def as_range
    start_time..end_time
  end

  def start_time_string
    "#{from_hour.to_s.rjust(2, "0")}:#{from_min.to_s.rjust(2, "0")}"
  end

  def end_time_string
    "#{to_hour.to_s.rjust(2, "0")}:#{to_min.to_s.rjust(2, "0")}"
  end

  # To double check overlapping logic
  #   see: https://stackoverflow.com/questions/13513932/algorithm-to-detect-overlapping-periods
  def overlapping_time_slots
    start_i = (from_hour + from_min / 60r).to_f
    end_i = (to_hour + to_min / 60r).to_f

    sql_start_i = Arel.sql("(from_hour + (from_min / 60.0))")
    sql_end_i = Arel.sql("(to_hour + (to_min / 60.0))")

    query_sql = <<-SQL.squish
      (
        SELECT ts.*,
               #{sql_start_i} as start_i,
               #{sql_end_i} as end_i
          FROM facility_time_slots ts
          WHERE (#{sql_start_i} <= #{end_i})
            AND (#{sql_end_i} >= #{start_i})
      ) as facility_time_slots
    SQL

    FacilityTimeSlot.from(query_sql).where(id: siblings_time_slots)
  end

  private

  def siblings_time_slots
    return FacilityTimeSlot.none if facility_schedule.blank?

    facility_schedule.time_slots.where.not(id: id)
  end

  def validate_non_overlaping_time_slot_range
    errors.add(:time_slot, "can't overlap for the same Facility Schedule") if overlapping_time_slots.exists? #if as_range.overlaps?()
  end

  def facility_availabity_is_set_times
    errors.add(:facility_schedule, "availabity must not be open all day") if facility_schedule.open_all_day?
    errors.add(:facility_schedule, "availabity must not be closed all day") if facility_schedule.closed_all_day?
  end
end
