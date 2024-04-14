# frozen_string_literal: true

class FacilityService < ApplicationRecord
  belongs_to :facility, touch: true
  belongs_to :service

  validates :facility, :service, presence: true
  validates :service, uniqueness: { scope: :facility }

  delegate :key, :name, to: :service

  scope :name_search, ->(value) { where(service: Service.name_search(value)) }
end
