module Locations::Providers
  class GeocoderCaParser < BaseParser
    private

    def address
      [standard_data['stnumber'], standard_data['staddress']]
    end

    def standard_data
      data['standard'] || {}
    end
  end
end
