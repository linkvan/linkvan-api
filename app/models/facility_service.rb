# frozen_string_literal: true

class FacilityService < ApplicationRecord
  belongs_to :facility, touch: true, inverse_of: :facility_services
  belongs_to :service, inverse_of: :facility_services

  validates :service, uniqueness: { scope: :facility }

  delegate :key, :name, to: :service

  scope :name_search, ->(value) { where(service: Service.name_search(value)) }
end
