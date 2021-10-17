FactoryBot.define do
  factory :facility_schedule do
    week_day { :monday }

    facility factory: :facility

    trait :with_time_slot do
      open_all_day { false }
      closed_all_day { false }

      after(:build) do |schedule|
        schedule.time_slots << build(:facility_time_slot, facility_schedule: schedule)
      end
    end

    trait :with_2_time_slots do
      open_all_day { false }
      closed_all_day { false }

      after(:build) do |schedule|
        schedule.time_slots << build(:facility_time_slot,
                                     facility_schedule: schedule,
                                     from_hour: 9,
                                     from_min: 0,
                                     to_hour: 11,
                                     to_min: 50)

        schedule.time_slots << build(:facility_time_slot,
                                     facility_schedule: schedule,
                                     from_hour: 12,
                                     from_min: 0,
                                     to_hour: 17,
                                     to_min: 0)
      end
    end
  end
end
