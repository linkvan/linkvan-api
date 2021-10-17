FactoryBot.define do
  factory :facility_time_slot do
    from_hour { 9 }
    from_min { 0 }
    to_hour { 17 }
    to_min { 0 }

    facility_schedule factory: :facility_schedule
  end
end
