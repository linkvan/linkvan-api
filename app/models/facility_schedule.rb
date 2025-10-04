# frozen_string_literal: true

class FacilitySchedule < ApplicationRecord
  belongs_to :facility, touch: true
  has_many :time_slots, class_name: "FacilityTimeSlot", dependent: :destroy

  enum :week_day, 
    sunday: "sunday",
    monday: "monday",
    tuesday: "tuesday",
    wednesday: "wednesday",
    thursday: "thursday",
    friday: "friday",
    saturday: "saturday"

  validates :week_day, presence: true, uniqueness: { scope: :facility_id }
  validate :time_slots_presence

  attribute :closed_all_day, :boolean, default: -> { true }
  attribute :open_all_day, :boolean, default: -> { false }

  # after_initialize :set_defaults, if: :new_record?

  scope :open_all_day, -> { where(open_all_day: true) }
  scope :closed_all_day, -> { where(closed_all_day: true) }
  scope :set_times, -> { join(:time_slots).where(open_all_day: false) }

  def availability
    return :open if open_all_day?
    return :set_times if time_slots.present?

    :closed
  end

  def update_schedule_availability
    if time_slots.present?
      update(closed_all_day: false, open_all_day: false)
    else
      update(closed_all_day: true, open_all_day: false) unless open_all_day?
    end
  end

  private

  SLOT_TIME_PRESENCE_ERROR = "must not be present if facility availability is %<availability>s all day for %<week_day>s"

  def time_slots_presence
    open_error_msg = format(SLOT_TIME_PRESENCE_ERROR, availability: :open, week_day: week_day)
    closed_error_msg = format(SLOT_TIME_PRESENCE_ERROR, availability: :closed, week_day: week_day)

    errors.add(:slot_times, open_error_msg) if open_all_day? && time_slots.present?
    errors.add(:slot_times, closed_error_msg) if closed_all_day? && time_slots.present?
  end
end
