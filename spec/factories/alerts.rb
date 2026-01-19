FactoryBot.define do
  factory :alert do
    sequence(:title) { |n| "Alert Title #{n}" }

    after(:build) do |alert|
      alert.content = "<p>Content for alert: #{alert.title}</p>"
    end

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
