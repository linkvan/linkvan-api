# frozen_string_literal: true

class Analytics::Visit < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :impressions, through: :events

  validates :uuid, presence: true
  validates :session_id, presence: true, uniqueness: { scope: :uuid }

  def attempt_update_coordinates(visit_params)
    # Only update coordinates if current coordinates are not set yet
    if [lat, long].any?(&:blank?)
      new_coordinates = extract_coordinates_from(visit_params)

      update(new_coordinates)
    end

    self
  end

  private

  def extract_coordinates_from(visit_params)
    visit_params.to_h.with_indifferent_access.slice(:lat, :long)
  end
end
