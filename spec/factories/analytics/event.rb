# frozen_string_literal: true

FactoryBot.define do
  factory :analytics_event, class: "Analytics::Event" do
    association :visit, factory: :analytics_visit

    controller_name { "facilities" }
    action_name { "index" }
    request_url { "https://example.com/facilities" }

    trait :show_action do
      action_name { "show" }
      request_url { "https://example.com/facilities/1" }
    end

    trait :create_action do
      action_name { "create" }
      request_url { "https://example.com/facilities" }
    end

    trait :update_action do
      action_name { "update" }
      request_url { "https://example.com/facilities/1" }
    end
  end
end
