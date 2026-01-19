FactoryBot.define do
  factory :zone do
    sequence(:name) { |n| "Zone #{n}" }
    description { "Description for zone #{name}" }

    factory :zone_with_facilities do
      transient do
        facilities_count { 3 }
      end

      after(:build) do |zone, evaluator|
        create_list(:facility, evaluator.facilities_count, zone: zone)
      end
    end

    factory :zone_with_users do
      transient do
        users_count { 2 }
      end

      after(:build) do |zone, evaluator|
        create_list(:user, evaluator.users_count).each do |user|
          zone.users << user
        end
      end
    end
  end
end
