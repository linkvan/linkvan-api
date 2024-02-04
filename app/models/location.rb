class Location
  extend ActiveModel::Naming

  attr_reader :address, :lat, :long, :facility

  def initialize(address:, lat:, long:, facility: nil)
    @address = address
    @lat = lat
    @long = long
    @facility = facility
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
    lat = facility&.lat || geocoder_location.latitude
    long = facility&.long || geocoder_location.longitude

    new(
      address:,
      lat:,
      long:,
      facility:
    )
  end

  def to_key
    [coordinates.hash]
  end

  def persisted?
    facility&.id.present?
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
