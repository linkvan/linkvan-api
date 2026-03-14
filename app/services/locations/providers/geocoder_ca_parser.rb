# frozen_string_literal: true

class Locations::Providers::GeocoderCaParser < Locations::Providers::BaseParser
  private

  def address
    [standard_data["stnumber"], standard_data["staddress"]]
  end

  def standard_data
    data["standard"] || {}
  end
end
