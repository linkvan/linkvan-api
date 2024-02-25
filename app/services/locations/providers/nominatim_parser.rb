module Locations::Providers
  class NominatimParser < BaseParser
    private

    def address
      [geocoded_result.house_number, geocoded_result.street].compact.join(" ")
    end
  end
end
