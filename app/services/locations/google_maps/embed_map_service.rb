require 'uri'

module Locations::GoogleMaps
  class EmbedMapService < ApplicationService
    GOOGLE_KEY = ENV['GOOGLE_MAPS_API_TOKEN']
    GOOGLE_SIGNATURE = nil
    BASE_URL = "https://maps.googleapis.com/maps/embed/v1/place"

    MAP_CONFIG = {
      url: BASE_URL,
      zoom: 14,
      # <horizontal>x<vertical>
      size: "400x400",
      maptype: "roadmap"
    }.freeze

    attr_reader :uri, :latitude, :longitude

    def initialize(latitude, longitude)
      super()

      @latitude = latitude
      @longitude = longitude

      @uri = URI.parse(MAP_CONFIG.fetch(:url))
    end

    def call
      uri.query = URI.encode_www_form(query_params)
      uri
    end

    private

    def query_params
      result = URI.decode_www_form(uri.query || "").to_h.symbolize_keys
      result[:center] = coordinates.join(",")
      result[:zoom] = MAP_CONFIG.fetch(:zoom)
      result[:maptype] = MAP_CONFIG.fetch(:maptype)
      # result[:size] = MAP_CONFIG.fetch(:size)
      # result[:markers] = markers.join("|")
      result[:q] = coordinates.join(",")

      result[:key] = GOOGLE_KEY
      result[:signature] = GOOGLE_SIGNATURE if GOOGLE_SIGNATURE.present?

      result
    end

    def markers
      ["color:red", "label:F", coordinates.join(",")]
    end

    # Google Maps only use 6 decimal places (ignores the rest)
    def coordinates
      [latitude.round(6), longitude.round(6)]
    end
  end
end
