module Locations
  GeocoderLocation = Struct.new(
    :address,
    :city,
    :state,
    :country,
    :postal_code,
    :latitude,
    :longitude,
    :data,
    :data_raw,
    keyword_init: true
  ) do
    def coordinates
      [latitude, longitude]
    end
  end
end
