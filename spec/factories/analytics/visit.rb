# frozen_string_literal: true

FactoryBot.define do
  factory :analytics_visit, class: "Analytics::Visit" do
    sequence(:uuid, 1000) { |n| "visit-#{n}-#{SecureRandom.hex(8)}" }
    sequence(:session_id, "aa") { |n| "session-#{n}-#{SecureRandom.hex(4)}" }

    # Coordinates are nullable - default to nil for basic factory
    lat { nil }
    long { nil }

    # Factory with coordinates
    trait :with_coordinates do
      lat { 49.2827 + ((rand - 0.5) * 0.1) } # Vancouver area with some variation
      long { -123.1207 + ((rand - 0.5) * 0.1) }
    end

    # Factory with specific Vancouver coordinates
    trait :vancouver_center do
      lat { 49.2827 }
      long { -123.1207 }
    end

    # Factory with downtown Vancouver coordinates
    trait :downtown_vancouver do
      lat { 49.2848 }
      long { -123.1228 }
    end

    # Factory with coordinates but slightly outside Vancouver
    trait :outside_vancouver do
      lat { 49.0 + (rand * 2) } # Random latitude around Vancouver area
      long { -123.0 + (rand * 2) } # Random longitude around Vancouver area
    end

    # Factory with invalid coordinates (negative latitude, positive longitude - wrong hemisphere)
    trait :invalid_coordinates do
      lat { -33.8688 } # Sydney, Australia
      long { 151.2093 }
    end

    # Trait for visits that need manual event creation
    trait :requires_events do
      # This trait indicates that events should be created manually in tests
      # Useful when you want to test associations without depending on event factories
    end

    # Trait for new session visits (different creation time)
    trait :new_session do
      transient do
        session_start_time { 1.hour.ago }
      end

      created_at { session_start_time }
      updated_at { session_start_time }
    end

    # Trait for returning session visits (updated later)
    trait :returning_session do
      transient do
        initial_visit_time { 1.day.ago }
        return_time { 10.minutes.ago }
      end

      created_at { initial_visit_time }
      updated_at { return_time }
    end

    # Trait for mobile session patterns
    trait :mobile_session do
      with_coordinates
      # Mobile sessions typically have coordinates and are updated more frequently
    end

    # Trait for desktop session patterns
    trait :desktop_session do
      # Desktop sessions typically don't have coordinates
      lat { nil }
      long { nil }
    end
  end
end
