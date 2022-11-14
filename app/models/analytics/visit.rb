# frozen_string_literal: true

class Analytics::Visit < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :impressions, through: :events

  validates :uuid, presence: true
  validates :session_id, presence: true, uniqueness: { scope: :uuid }
end
