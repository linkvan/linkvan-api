# frozen_string_literal: true

class ZoneSerializer < ApplicationService
  include Serializable

  ATTRIBUTES = %i[id name description].freeze

  def initialize(zone)
    super()

    @zone = zone
  end

  def call
    data = hashify(@zone, ATTRIBUTES)
    data[:facilities] = hashify_facilities
    data[:users] = hashify_users

    data.symbolize_keys
  end

  private

  def hashify_facilities
    @zone.facilities.map do |facility|
      {
        id: facility.id,
        name: facility.name,
        lat: facility.lat.to_s,
        long: facility.long.to_s
      }
    end
  end

  def hashify_users
    @zone.users.map do |user|
      {
        id: user.id,
        name: user.name,
        email: user.email
      }
    end
  end
end
