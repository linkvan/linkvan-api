# frozen_string_literal: true

class FacilityService < ApplicationRecord
  belongs_to :facility
  belongs_to :service

  validates :facility, :service, presence: true
  validates :service, uniqueness: { scope: :facility }

  delegate :key, :name, to: :service
end
