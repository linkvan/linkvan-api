# frozen_string_literal: true

class FacilitySchedule < ApplicationRecord
  belongs_to :facility
  has_many :time_slots, class_name: "FacilityTimeSlot", dependent: :destroy

  enum week_day: {
    sunday: "sunday",
    monday: "monday",
    tuesday: "tuesday",
    wednesday: "wednesday",
    thursday: "thursday",
    friday: "friday",
    saturday: "saturday"
  }

  validates :week_day, presence: true, uniqueness: { scope: :facility_id }

  validate :time_slots_presence

  scope :open_all_day, -> { where(open_all_day: true) }
  scope :closed_all_day, -> { where(closed_all_day: true) }
  scope :set_time, -> { where(open_all_day: false).where(closed_all_day: false) }

  def availability
    return :open if open_all_day?
    return :closed if closed_all_day?

    :set_times
  end

  private

    SLOT_TIME_PRESENCE_ERROR = "must not be present if facility availability is %{availability} all day for %{week_day}"

    def time_slots_presence
      # errors.add(:slot_times, "must not be present if facility schedule availability is open all day") if open_all_day?
      # errors.add(:slot_times, "must not be present if facility schedule availability is closed all day") if closed_all_day?

      open_error_msg = SLOT_TIME_PRESENCE_ERROR % { availability: :open, week_day: week_day }
      closed_error_msg = SLOT_TIME_PRESENCE_ERROR % { availability: :closed, week_day: week_day }

      errors.add(:slot_times, open_error_msg) if open_all_day? && time_slots.present?
      errors.add(:slot_times, closed_error_msg) if closed_all_day? && time_slots.present?
    end
end
