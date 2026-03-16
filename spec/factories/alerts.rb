FactoryBot.define do
  factory :alert do
    sequence(:title) { |n| "Alert Title #{n}" }

    content { "<p>Content for alert: #{title}</p>" }

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
