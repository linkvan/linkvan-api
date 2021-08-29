FactoryBot.define do
  factory :facility do
    id { 1 }
    name { "Test Facility" }
    welcomes { "male female transgender children youth adult senior" }
    services { " Legal" }
    lat { 49.2450424 }
    long { -123.02894679999997 }
    address { "address of facility" }
    phone { "123" }
    website { "www.facility.test" }
    description { "description of the facility" }
    notes { "small notes about facility" }
    verified { true }

    second_time_mon { false }
    second_time_tues { false }
    second_time_wed { false }
    second_time_thurs { false }
    second_time_fri { false }
    second_time_sat { false }
    second_time_sun { false }

    # Facility is open all day
    factory :open_all_day_facility do
      open_all_day_mon { true }
      open_all_day_tues { true }
      open_all_day_wed { true }
      open_all_day_thurs { true }
      open_all_day_fri { true }
      open_all_day_sat { true }
      open_all_day_sun { true }

      closed_all_day_mon { !open_all_day_mon }
      closed_all_day_tues { !open_all_day_tues }
      closed_all_day_wed { !open_all_day_wed }
      closed_all_day_thurs { !open_all_day_thurs }
      closed_all_day_fri { !open_all_day_fri }
      closed_all_day_sat { !open_all_day_sat }
      closed_all_day_sun { !open_all_day_sun }
    end

    # Facility is closed all day
    factory :close_all_day_facility do
      open_all_day_mon { false }
      open_all_day_tues { false }
      open_all_day_wed { false }
      open_all_day_thurs { false }
      open_all_day_fri { false }
      open_all_day_sat { false }
      open_all_day_sun { false }
    end

    # Facility is open and has time set.
    factory :open_facility do
      startsmon_at { 2.hours.ago }
      endsmon_at { 2.hours.from_now }
      startstues_at { 2.hours.ago }
      endstues_at { 2.hours.from_now }
      startswed_at { 2.hours.ago }
      endswed_at { 2.hours.from_now }
      startsthurs_at { 2.hours.ago }
      endsthurs_at  { 2.hours.from_now }
      startsfri_at  { 2.hours.ago }
      endsfri_at { 2.hours.from_now }
      startssat_at { 2.hours.ago }
      endssat_at { 2.hours.from_now }
      startssun_at { 2.hours.ago }
      endssun_at { 2.hours.from_now }

      # Facility has two times set for the same day.
      factory :open2_facility do
        second_time_mon { true }
        second_time_tues { true }
        second_time_wed { true }
        second_time_thurs { true }
        second_time_fri { true }
        second_time_sat { true }
        second_time_sun { true }

        startsmon_at2 { 3.hours.from_now }
        endsmon_at2 { startsmon_at2 + 1.hour }
        startstues_at2 { 3.hours.from_now }
        endstues_at2 { startstues_at2 + 1.hour }
        startswed_at2 { 3.hours.from_now }
        endswed_at2 { startswed_at2 + 1.hour }
        startsthurs_at2 { 3.hours.from_now }
        endsthurs_at2 { startsthurs_at2 + 1.hour }
        startsfri_at2 { 3.hours.from_now }
        endsfri_at2 { startsfri_at2 + 1.hour }
        startssat_at2 { 3.hours.from_now }
        endssat_at2 { startssat_at2 + 1.hour }
        startssun_at2 { 3.hours.from_now }
        endssun_at2 { endssun_at2 + 1.hour }
      end
    end

    # Facility is closed and has time set.
    factory :close_facility do
    end
  end

  # Remove these fields
  # "r_pets": false,
  # "r_id": false,
  # "r_cart": false,
  # "r_phone": false,
  # "r_wifi": false,
end
