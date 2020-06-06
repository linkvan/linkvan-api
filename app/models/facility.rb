require 'bigdecimal'
require 'bigdecimal/util'

class Facility < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :zone, optional: true

  validates :name, :lat, :long, :services, presence: true

  # is_impressionable

  scope :is_verified, lambda {
    where(verified: true)
  }

  scope :keywordSearch, lambda  { |word|
    where(["services ILIKE ? OR welcomes ILIKE ?", "%#{word}%", "%#{word}%"]) unless word == 'all'
  }

  def managed_by?(user)
    if user.respond_to? :id
      f_user_id = user.id
    else
      f_user_id = user
    end
    # Case Facility's User is the same
    return true if (this.user_id == f_user_id)
    # Case Zone of the Facility has the user as admin
    return true if User.find(f_user_id).manages.any?

    # Otherwise return FALSE
    return false
  end #/managed_by?

  def self.managed_by(user)
    user.manages
  end #/owned_by

  def self.search(search)
    return all if search.empty?

    where("name ILIKE ?", "%#{search}%")
  end #/search

  def self.search_by_services(search)
    where("services ILIKE ?", "%#{search}%")
  end #/search_by_services

  def self.adjusted_current_time
    # Returns current server time subtracted by 8 hours.
    8.hours.ago
  end #/adjusted_current_time

  def schedule
    result = HashWithIndifferentAccess.new
    wday_names = Date::DAYNAMES
    7.times.each do |week_day_num|
      d_name = wday_names[week_day_num].to_s.downcase
      result[d_name] = schedule_for(week_day_num)
    end
    result
  end

  # Return list of fields related with schedule
  def self.schedule_fields
    result = []
    7.times.each do |week_day|
      wday = weekdays[week_day]
      result += ["open_all_day_#{wday}",
                 "closed_all_day_#{wday}",
                 "second_time_#{wday}",
                 "starts#{wday}_at",
                 "ends#{wday}_at",
                 "starts#{wday}_at2",
                 "ends#{wday}_at2"]
    end
    result
  end

  def self.weekdays
    [:sun, :mon, :tues, :wed, :thurs, :fri, :sat]
  end

  def schedule_for(week_day)
    cday = week_day % 7 #-> sun= 0, mon=1, ..., sat=6 
    # cday = DateTime.wday
    wday = self.class.weekdays[cday]

    availability = 'set_times'
    if self["open_all_day_#{wday}"]
      availability = "open"
    elsif self["closed_all_day_#{wday}"]
      availability = "closed"
    end

    times = []
    if availability == 'set_times'
      start_time = self["starts#{wday}_at"].to_s(:time).split(':')
      end_time = self["ends#{wday}_at"].to_s(:time).split(':')
      times << { from_hour: start_time.first,
                 from_min: start_time.last,
                 to_hour: end_time.first,
                 to_min: end_time.last }
      if self["second_time_#{wday}"]
        start_time = self["starts#{wday}_at2"].to_s(:time).split(':')
        end_time = self["ends#{wday}_at2"].to_s(:time).split(':')
        times << { from_hour: start_time.first,
                   from_min: start_time.last,
                   to_hour: end_time.first,
                   to_min: end_time.last }
      end
    end
    { availability: availability, times: times }.with_indifferent_access
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
    return ret
  end #/is_open?

  def is_closed?(ctime = Facility.adjusted_current_time)
    !is_open?(ctime)
  end #/is_closed?

  def time_in_range?(ctime, wday)
    # We consider Facilities opening in 5 mins as an Opened Facilty.
    open1  = Facility.translate_time(ctime, self["starts#{wday}_at"])
    open2  = Facility.translate_time(ctime, self["starts#{wday}_at2"])
    close1 = Facility.translate_time(ctime, self["ends#{wday}_at"])
    close2 = Facility.translate_time(ctime, self["ends#{wday}_at2"])
    open1 = 5.minutes.until(open1)
    open2 = 5.minutes.until(open2)
    close1 = 5.minutes.until(close1)
    close2 = 5.minutes.until(close2)

    if (ctime >= open1 && ctime < close1) || (ctime >= open2 && ctime < close2)
      return true
    else
      return false
    end
  end #/time_in_range?

  def self.translate_time(cdate, ftime)
    newdate = cdate.strftime('%Y-%m-%d')
    newtime = ftime&.to_s(:time)
    newzone = ftime&.zone
    # cdate = ctime.strftime('%I:%M:%P')
    Time.zone.parse("#{newdate} #{newtime} #{newzone}")
  end #/translate_time

  def distance(ulat, ulong)
    Facility.haversine(self[:lat], self[:long], ulat, ulong)
  end

  def self.contains_service(service_query, prox, open, ulat, ulong)
    # TODO: This method could be improved:
    #   - Fields like 'endsun_at' are using full DateTime, which makes
    #         impossible to reasonably check open/closed facilities.
    #  - This method also compares open and close times with 8.hours.ago.
    #         If this is related with timezone, we should probably change it.
    ulat = ulat.to_d
    ulong = ulong.to_d

    # Using 30 mins delay to show "Opening Soon" and "Closing Soon" facilities.
    ctime = Facility.adjusted_current_time + 30.minutes

    # First query db for any verified facility whose services contains the service_query
    #   and store in searched_facilities
    searched_facilities = Facility.search_by_services(service_query).is_verified

    # Select Opened/Closed facilities
    selected_facilities = []
    searched_facilities.each do |facility|
      if (open == "Yes")
        selected_facilities.push facility if facility.is_open?(ctime)
      elsif (open == "No")
        selected_facilities.push facility if facility.is_closed?(ctime)
      else
        # Only for Testing purposes (should delete these lines later)
        return []
        # raise 'Error! Should not go into this one'
      end
    end #/searched_facilities.each

    # Sorts out selected facilities.
    ret_arr = []
    if (prox == "Near")
      ret_arr = selected_facilities.sort_by { |f| f.distance(ulat, ulong) }
    elsif (prox == "Name")
      ret_arr = selected_facilities.sort_by(&:name)
    end #/prox == Near, Name

    return ret_arr
  end #ends self.contains_service?

  def self.redist_sort(inArray, ulat, ulong)
    ulat = ulat.to_d
    ulong = ulong.to_d
    arr = []
    distarr = []

    inArray.each do |a|
      distarr.push(Facility.haversine(a.lat, a.long, ulat, ulong))
    end

    arr = Facility.bubble_sort(distarr, inArray)

    return arr
  end

  #use haversine and power to calculate distance between user's latlongs and facilities'
  def self.haversine(lat1, long1, lat2, long2)
    dtor = Math::PI / 180
    r = 6378.14 * 1000 #delete 1000 to get kms

    rlat1 = lat1 * dtor
    rlong1 = long1 * dtor
    rlat2 = lat2 * dtor
    rlong2 = long2 * dtor

    dlon = rlong1 - rlong2
    dlat = rlat1 - rlat2

    a = power(Math.sin(dlat / 2), 2) + Math.cos(rlat1) * Math.cos(rlat2) * power(Math.sin(dlon / 2), 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    d = r * c

    return d
  end

  def self.haversine_km(lat1, long1, lat2, long2)
    dtor = Math::PI / 180
    r = 6378.14

    rlat1 = lat1 * dtor
    rlong1 = long1 * dtor
    rlat2 = lat2 * dtor
    rlong2 = long2 * dtor

    dlon = rlong1 - rlong2
    dlat = rlat1 - rlat2

    a = power(Math.sin(dlat / 2), 2) + Math.cos(rlat1) * Math.cos(rlat2) * power(Math.sin(dlon / 2), 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    d = r * c

    return d
  end

  def self.haversine_min(lat1, long1, lat2, long2)
    km = haversine_km(lat1, long1, lat2, long2)
    time = km * 12.2 * 60 # avegrage 12.2 min/km walking
    return time.round(0) # time in seconds
  end

  def self.power(num, pow)
    num**pow
  end

  # Sorts alist using list values as parameters
  #   Used in #contains_service to sort facilities by distance
  def self.bubble_sort(list, alist)
    return alist if list.size <= 1 # already sorted

    swapped = true
    while swapped
      swapped = false
      0.upto(list.size - 2) do |i|
        next unless list[i] > list[i + 1]

        list[i], list[i + 1] = list[i + 1], list[i] # swap values
        alist[i], alist[i + 1] = alist[i + 1], alist[i]
        swapped = true
      end
    end

    alist
  end

  def self.rename_sort(inArray)
    arr = []
    arr = inArray.sort_by { |f| f[:name] }
    return arr
  end

  def self.to_csv
    attributes = %w[id name welcomes services lat long address phone website description notes created_at updated_at startsmon_at endsmon_at startstues_at endstues_at startswed_at endswed_at startsthurs_at endsthurs_at startsfri_at endsfri_at startssat_at endssat_at startssun_at endssun_at r_pets r_id r_cart r_phone r_wifi startsmon_at2 endsmon_at2 startstues_at2 endstues_at2 startswed_at2 endswed_at2 startsthurs_at2 endsthurs_at2 startsfri_at2 endsfri_at2 startssat_at2 endssat_at2 startssun_at2 endssun_at2 open_all_day_mon open_all_day_tues open_all_day_wed open_all_day_thurs open_all_day_fri open_all_day_sat open_all_day_sun closed_all_day_mon closed_all_day_tues closed_all_day_wed closed_all_day_thurs closed_all_day_fri closed_all_day_sat closed_all_day_sun second_time_mon second_time_tues second_time_wed second_time_thurs second_time_fri second_time_sat second_time_sun user_id verified shelter_note food_note medical_note hygiene_note technology_note legal_note learning_note]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |facility|
        csv << attributes.map { |attr| facility.send(attr) }
      end
    end
  end
end #ends class
