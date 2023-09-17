# frozen_string_literal: true

module Localizable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def search(address: nil)
      # Uses Geocoder gem to search for locations:
      #   see: https://github.com/alexreisner/geocoder
      #        https://github.com/alexreisner/geocoder#geocoding-service-lookup-configuration
      search_results = Geocoder.search(address)

      search_results
        .lazy
        .map { Locations::Parser.parse(_1) }
        .map { build_from_parser(_1) }
    end

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
end
