# frozen_string_literal: true

FactoryBot.define do
  factory :analytics_impression, class: "Analytics::Impression" do
    association :event, factory: :analytics_event
    association :impressionable, factory: :facility

    trait :for_service do
      association :impressionable, factory: :service
    end

    trait :for_zone do
      association :impressionable, factory: :zone
    end
  end
end
