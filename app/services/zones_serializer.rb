# frozen_string_literal: true

class ZonesSerializer < ApplicationService
  include Serializable

  ATTRIBUTES = %i[id name description].freeze

  def initialize(zones)
    super()

    @zones = zones
  end

  def call
    data = @zones.map { |zone| serialize_zone(zone) }

    { zones: data }
  end

  private

  def serialize_zone(zone)
    zone_data = hashify(zone, ATTRIBUTES)
    zone_data[:facilities] = hashify_facilities(zone)
    zone_data[:users] = hashify_users(zone)
    zone_data.symbolize_keys
  end

  def hashify_facilities(zone)
    zone.facilities.map do |facility|
      {
        id: facility.id,
        name: facility.name,
        lat: facility.lat.to_s,
        long: facility.long.to_s
      }
    end
  end

  def hashify_users(zone)
    zone.users.map do |user|
      {
        id: user.id,
        name: user.name,
        email: user.email
      }
    end
  end
end
