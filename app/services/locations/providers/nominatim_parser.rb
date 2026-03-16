# frozen_string_literal: true

class Locations::Providers::NominatimParser < Locations::Providers::BaseParser
  private

  def address
    [geocoded_result.house_number, geocoded_result.street].compact.join(" ")
  end
end
