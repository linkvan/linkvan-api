class Locations::Searcher < ApplicationService
  attr_reader :address

  def initialize(address: nil)
    @address = address
  end

  def call
    search_result = Geocoder.search(address)

    search_result
      .lazy
      .map { Locations::Parser.parse(_1) }
  end
end
