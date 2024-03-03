# frozen_string_literal: true

class GeoLocation
  Coord = Struct.new(:lat, :long)

  def initialize(address:, city:, lat:, long:)
  end

  class << self
    def coord(lat, long)
      Coord.new(lat, long)
    end

    def distance(from_coord, to_coord)
      # Uses Haversine gem to make distance calculations.
      #    https://github.com/fabionl/haversine
      Haversine.distance(from_coord.lat, from_coord.long, to_coord.lat, to_coord.long)
      # from_coord.distance(to_coord)
    end

    def find_by_address(address, params: { countrycodes: "ca" })
      coord(*Geocoder.coordinates(address, params))
    end

    # , &block)
    def search(*args)
      Geocoder.search(*args)
    end
  end
end

# These are previous distance related calculations on Facility model.
#   Keeping it just for historical reasons, and will probably remove them.
#
#
# def distance(from_lat, from_long, to_lat, to_long)
# haversine(from_lat, from_long, to_lat, to_long)
# end
#
# def redist_sort(inArray, ulat, ulong)
# ulat = ulat.to_d
# ulong = ulong.to_d
# distarr = []
#
# inArray.each do |a|
# distarr.push(Facility.haversine(a.lat, a.long, ulat, ulong))
# end
#
# arr = Facility.bubble_sort(distarr, inArray)
#
# arr
# end

# use haversine and power to calculate distance between user's latlongs and facilities'
# def haversine(from_lat, from_long, to_lat, to_long)
# def self.haversine(from_lat, from_long, to_lat, to_long)
# dtor = Math::PI / 180
# r = 6378.14 * 1000 # delete 1000 to get kms
#
# rfrom_lat = from_lat * dtor
# rfrom_long = from_long * dtor
# rto_lat = to_lat * dtor
# rto_long = to_long * dtor
#
# dlon = rfrom_long - rto_long
# dlat = rfrom_lat - rto_lat
#
# a = power(Math.sin(dlat / 2), 2) + Math.cos(rfrom_lat) * Math.cos(rto_lat) * power(Math.sin(dlon / 2), 2)
# c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
# d = r * c
#
# d
# end

# def haversine_km(from_lat, from_long, to_lat, to_long)
# dtor = Math::PI / 180
# r = 6378.14
#
# rfrom_lat = from_lat * dtor
# rfrom_long = from_long * dtor
# rto_lat = to_lat * dtor
# rto_long = to_long * dtor
#
# dlon = rfrom_long - rto_long
# dlat = rfrom_lat - rto_lat
#
# a = power(Math.sin(dlat / 2), 2) + Math.cos(rfrom_lat) * Math.cos(rto_lat) * power(Math.sin(dlon / 2), 2)
# c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
# d = r * c
#
# d
# end

# def haversine_min(from_lat, from_long, to_lat, to_long)
# km = haversine_km(from_lat, from_long, to_lat, to_long)
# time = km * 12.2 * 60 # avegrage 12.2 min/km walking
# time.round(0) # time in seconds
# end

# def self.power(num, pow)
# num**pow
# end

# Sorts alist using list values as parameters
#   Used in #contains_service to sort facilities by distance
# def bubble_sort(list, alist)
# return alist if list.size <= 1 # already sorted
#
# swapped = true
# while swapped
# swapped = false
# 0.upto(list.size - 2) do |i|
# next unless list[i] > list[i + 1]
#
# list[i], list[i + 1] = list[i + 1], list[i] # swap values
# alist[i], alist[i + 1] = alist[i + 1], alist[i]
# swapped = true
# end
# end
#
# alist
# end
