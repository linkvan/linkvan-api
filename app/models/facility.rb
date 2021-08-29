# frozen_string_literal: true

require "ostruct"
require "bigdecimal"
require "bigdecimal/util"

class Facility < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :zone, optional: true

  has_many :facility_welcomes
  has_many :facility_services
  has_many :services, through: :facility_services
  has_many :schedules, class_name: "FacilitySchedule", dependent: :destroy
  has_many :time_slots, through: :schedules

  # WELCOMES = %w[male female transgender children youth adult senior].freeze


  validates :name, :lat, :long, presence: true


  # is_impressionable

  scope :is_verified, lambda {
    where(verified: true)
  }

  scope :keywordSearch, lambda  { |word|
    where(["services ILIKE ? OR welcomes ILIKE ?", "%#{word}%", "%#{word}%"]) unless word == "all"
  }


  def managed_by?(user)
    if user.respond_to? :id
      f_user_id = user.id
    else
      f_user_id = user
    end
    # Case Facility's User is the same
    return true if this.user_id == f_user_id
    # Case Zone of the Facility has the user as admin
    return true if User.find(f_user_id).manages.any?

    # Otherwise return FALSE
    false
  end # /managed_by?

  def self.managed_by(user)
    user.manages
  end # /owned_by

  def self.search(search)
    return all if search.empty?

    where("name ILIKE ?", "%#{search}%")
  end # /search

  def self.search_by_services(search)
    where("services ILIKE ?", "%#{search}%")
  end # /search_by_services

  def self.adjusted_current_time
    # Returns current server time subtracted by 8 hours.
    8.hours.ago
  end # /adjusted_current_time

  def status
    if verified?
      :live
    else
      :pending_reviews
    end
  end

  def coord
    GeoLocation.coord(lat, long)
  end

  def distance(to_coord = nil, to_lat: nil, to_long: nil, to_facility: nil)
    to_coord = to_facility.coord if to_facility.respond_to?(:coord) && to_coord.blank?
    to_coord = GeoLocation.coord(to_lat, to_long) unless to_coord.present?

    GeoLocation.distance(coord, to_coord)
  end

  def distance_in_meters(*params)
    distance(*params).to_meters
  end

  def distance_in_kms(*params)
    distance(*params).to_kilometers
  end

  def is_open?(ctime = Facility.adjusted_current_time)
    cday = ctime.wday
    wday = self.class.weekdays[cday]
    ret = false
    if self["open_all_day_#{wday}"]
      ret = true
    elsif self["closed_all_day_#{wday}"]
      ret = false
    elsif self["second_time_#{wday}"]
      ret = true
    elsif time_in_range?(ctime, wday)
      ret = true
    end
    ret
  end # /is_open?

  def is_closed?(ctime = Facility.adjusted_current_time)
    !is_open?(ctime)
  end # /is_closed?

  # def time_in_range?(ctime, wday)
    # # We consider Facilities opening in 5 mins as an Opened Facilty.
    # open1  = Facility.translate_time(ctime, self["starts#{wday}_at"])
    # open2  = Facility.translate_time(ctime, self["starts#{wday}_at2"])
    # close1 = Facility.translate_time(ctime, self["ends#{wday}_at"])
    # close2 = Facility.translate_time(ctime, self["ends#{wday}_at2"])
    # open1 = 5.minutes.until(open1)
    # open2 = 5.minutes.until(open2)
    # close1 = 5.minutes.until(close1)
    # close2 = 5.minutes.until(close2)
# 
    # if (ctime >= open1 && ctime < close1) || (ctime >= open2 && ctime < close2)
      # true
    # else
      # false
    # end
  # end # /time_in_range?

  # def self.translate_time(cdate, ftime)
    # newdate = cdate.strftime("%Y-%m-%d")
    # newtime = ftime&.to_s(:time)
    # newzone = ftime&.zone
    # # cdate = ctime.strftime('%I:%M:%P')
    # Time.zone.parse("#{newdate} #{newtime} #{newzone}")
  # end # /translate_time

  # def self.contains_service(service_query, prox, open, ulat, ulong)
    # # TODO: This method could be improved:
    # #   - Fields like 'endsun_at' are using full DateTime, which makes
    # #         impossible to reasonably check open/closed facilities.
    # #  - This method also compares open and close times with 8.hours.ago.
    # #         If this is related with timezone, we should probably change it.
    # ulat = ulat.to_d
    # ulong = ulong.to_d
# 
    # # Using 30 mins delay to show "Opening Soon" and "Closing Soon" facilities.
    # ctime = Facility.adjusted_current_time + 30.minutes
# 
    # # First query db for any verified facility whose services contains the service_query
    # #   and store in searched_facilities
    # searched_facilities = Facility.search_by_services(service_query).is_verified
# 
    # # Select Opened/Closed facilities
    # selected_facilities = []
    # searched_facilities.each do |facility|
      # if open == "Yes"
        # selected_facilities.push facility if facility.is_open?(ctime)
      # elsif open == "No"
        # selected_facilities.push facility if facility.is_closed?(ctime)
      # else
        # # Only for Testing purposes (should delete these lines later)
        # return []
        # # raise 'Error! Should not go into this one'
      # end
    # end # /searched_facilities.each
# 
    # # Sorts out selected facilities.
    # ret_arr = []
    # if prox == "Near"
      # ret_arr = selected_facilities.sort_by { |f| f.distance(ulat, ulong) }
    # elsif prox == "Name"
      # ret_arr = selected_facilities.sort_by(&:name)
    # end # /prox == Near, Name
# 
    # ret_arr
  # end # ends self.contains_service?

  # def self.rename_sort(inArray)
    # inArray.sort_by { |f| f[:name] }
  # end

  # def self.to_csv
    # attributes = %w[id name welcomes services lat long address phone website description notes created_at updated_at startsmon_at endsmon_at startstues_at endstues_at startswed_at endswed_at startsthurs_at endsthurs_at startsfri_at endsfri_at startssat_at endssat_at startssun_at endssun_at r_pets r_id r_cart r_phone r_wifi startsmon_at2 endsmon_at2 startstues_at2 endstues_at2 startswed_at2 endswed_at2 startsthurs_at2 endsthurs_at2 startsfri_at2 endsfri_at2 startssat_at2 endssat_at2 startssun_at2 endssun_at2 open_all_day_mon open_all_day_tues open_all_day_wed open_all_day_thurs open_all_day_fri open_all_day_sat open_all_day_sun closed_all_day_mon closed_all_day_tues closed_all_day_wed closed_all_day_thurs closed_all_day_fri closed_all_day_sat closed_all_day_sun second_time_mon second_time_tues second_time_wed second_time_thurs second_time_fri second_time_sat second_time_sun user_id verified shelter_note food_note medical_note hygiene_note technology_note legal_note learning_note]
# 
    # CSV.generate(headers: true) do |csv|
      # csv << attributes
# 
      # all.find_each do |facility|
        # csv << attributes.map { |attr| facility.send(attr) }
      # end
    # end
  # end
end # ends class
