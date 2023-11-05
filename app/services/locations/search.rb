class Locations::Search
  attr_reader :address

  def initialize(address: nil)
    @address = address
  end

  def call
    search_result = Geocoder.search(address)

    search_result
      .lazy
      .map { Locations::Parser.parse(_1) }
      .map { build_from_parser(_1) }
  end

  private

  def build_from_parser(parsed_location)
    new(
      address: parsed_location.address,
      city: parsed_location.city,
      latitude: parsed_location.latitude,
      longitude: parsed_location.longitude,
      data_raw: parsed_location.data.to_json
    )
  end
end
