class Location
  extend ActiveModel::Naming

  attr_reader :address, :city, :lat, :long, :facility_id

  def initialize(address:, city:, lat:, long:, facility_id: nil)
    @address = address
    @city = city
    @lat = lat
    @long = long
    @facility_id = facility_id
  end

  def self.build(params)
    values_hash = params.to_h.symbolize_keys

    new(**values_hash)
  end

  def self.build_from(geocoder_location: nil, facility: nil)
    raise ArgumentError if geocoder_location.nil? && facility.nil?
    raise ArgumentError if geocoder_location.present? && facility.present?

    address_components = [facility&.address,
                          geocoder_location&.address,
                          geocoder_location&.city,
                          geocoder_location&.state,
                          geocoder_location&.postal_code]

    address = address_components.compact.join(", ")
    city = facility&.city || geocoder_location&.city
    lat = facility&.lat || geocoder_location.latitude
    long = facility&.long || geocoder_location.longitude
    facility_id = facility&.id

    new(
      address:,
      city:,
      lat:,
      long:,
      facility_id:
    )
  end

  def persisted?
    @facility_id.present?
  end

  def coordinates
    [lat, long]
  end

  def distance_from(*coords)
    # Uses Haversine gem to make distance calculations.
    #    https://github.com/fabionl/haversine
    Haversine.distance(lat, long, *coords)
  end
end

# class FacilityLocation < ApplicationRecord
  # belongs_to :facility
# 
  # validates :latitude, :longitude, presence: true
  # validates :address, :city, presence: true
# 
  # def data
    # JSON.parse(data_raw || "", symbolize_names: true)
  # rescue JSON::ParserError
    # nil
  # end
# 
  # def coordinates
    # [latitude, longitude]
  # end
# end
