# frozen_string_literal: true

class Locations::EmbedMapComponent < ViewComponent::Base
  attr_reader :status, :variant, :options

  CONFIG = {
    width: "100%",
    height: "400",
    style: "border:0",
    frameborder: "0",
    referrerpolicy: "no-referrer-when-downgrade"
  }.freeze

  def initialize(lat, long, **options)
    super()

    @lat = lat
    @long = long

    @options = CONFIG.dup
    options.each_pair do |key, value|
      sym_key = key.to_s.to_sym
      @options[sym_key] = value
    end
  end

  def render?
    @lat.present? && @long.present?
  end

  def call
    tag.iframe(**options.merge(src: embed_map_url))
  end

  private

  def embed_map_url
    Locations::GoogleMaps::EmbedMapService.call(*coordinates)
  end

  def coordinates
    [@lat, @long]
  end
end
