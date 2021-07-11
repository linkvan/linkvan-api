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

  validate :facility_availabity_is_set_times

  def from_time
    "#{from_hour.to_s.rjust(2, "0")}:#{from_min.to_s.rjust(2, "0")}"
  end

  def to_time
    "#{to_hour.to_s.rjust(2, "0")}:#{to_min.to_s.rjust(2, "0")}"
  end

  private

    def facility_availabity_is_set_times
      errors.add(:facility_schedule, "availabity must not be open all day") if facility_schedule.open_all_day?
      errors.add(:facility_schedule, "availabity must not be closed all day") if facility_schedule.closed_all_day?
    end
end
