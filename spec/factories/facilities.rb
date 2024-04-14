FactoryBot.define do
  factory :facility do
    name { "Test Facility" }
    address { "address of facility" }
    phone { "123" }
    website { "www.facility.test" }
    notes { "small notes about facility" }
    verified { false }

    trait :with_verified do
      lat { 49.2450424 }
      long { -123.02894679999997 }
      verified { true }
    end

    # Facility is open all day
    factory :open_all_day_facility do
      after(:build) do |facility|
        FacilitySchedule.week_days.each_key do |week_day|
          facility.schedules << build(:facility_schedule, open_all_day: true, facility: facility, week_day: week_day)
        end
      end
    end

    # Facility is closed all day
    factory :close_all_day_facility

    # Facility is open and has time set.
    factory :open_facility do
      after(:build) do |facility|
        FacilitySchedule.week_days.each_key do |week_day|
          facility.schedules << build(:facility_schedule, :with_time_slot, facility: facility, week_day: week_day)
        end
      end
    end

    factory :open_facility_with_2_time_slots do
      after(:build) do |facility|
        FacilitySchedule.week_days.each_key do |week_day|
          facility.schedules << build(:facility_schedule, :with_2_time_slots, facility: facility, week_day: week_day)
        end
      end
    end

    # Facility is closed and has time set.
    factory :close_facility
  end

  trait :with_services do
    after(:build) do |facility|
      facility.facility_services << build(:facility_service, facility: facility)
    end
  end

  # Remove these fields
  # "r_pets": false,
  # "r_id": false,
  # "r_cart": false,
  # "r_phone": false,
  # "r_wifi": false,
end
