# frozen_string_literal: true

# Vendored implementation of the haversine great-circle distance formula.
#
# Replaces the unmaintained `haversine` gem (last published release: 0.3.2 in
# 2016) and the personal git fork that was previously pinned in the Gemfile.
# Vendoring keeps the dependency tree smaller and lets Dependabot track the
# rest of the bundle without a blind spot.
#
# https://en.wikipedia.org/wiki/Haversine_formula
module Haversine
  RAD_PER_DEG = Math::PI / 180

  class << self
    # Distance between two latitude/longitude points.
    #
    # Returns a Haversine::Distance value object exposing the great circle
    # distance in several units.
    def distance(lat1, long1, lat2, long2)
      raise ArgumentError, "coordinates must not be nil" if [lat1, long1, lat2, long2].any?(&:nil?)

      dlat = lat2 - lat1
      dlon = long2 - long1

      a = calc(dlat, lat1, lat2, dlon)
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      Distance.new(c)
    end

    private

    def calc(dlat, lat1, lat2, dlon)
      (Math.sin(rpd(dlat) / 2)**2) +
        (Math.cos(rpd(lat1)) * Math.cos(rpd(lat2)) * (Math.sin(rpd(dlon) / 2)**2))
    end

    # Radians per degree
    def rpd(num)
      num * RAD_PER_DEG
    end
  end
end
