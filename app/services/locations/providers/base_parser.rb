module Locations::Providers
  class BaseParser
    attr_reader :geocoded_result

    def initialize(geocoded_result)
      @geocoded_result = geocoded_result
    end

    def self.call(...)
      new(...).call
    end

    def call
      Locations::GeoCoderLocation.new(
        address:,
        city:,
        state:,
        country:,
        postal_code:,
        latitude:,
        longitude:,
        data:
      )
    end

    private

    delegate :city,
             :state,
             :country,
             :postal_code,
             :latitude,
             :longitude,
             :data,
             to: :geocoded_result

    def address
      geocoded_result.street_address.to_s.strip
    end
  end
end
