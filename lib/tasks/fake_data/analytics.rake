# frozen_string_literal: true

namespace :fake_data do
  desc "Create Analytics fake data to help development"
  task analytics: :environment do
    # Allow running in production if ALLOW_FAKE_DATA is set (for local testing)
    unless Rails.env.development? || ENV['ALLOW_FAKE_DATA'].present?
      abort "This script can only be run on development environment. Set ALLOW_FAKE_DATA=true to override."
    end

    # Check if Faker is available
    begin
      require 'faker'
    rescue LoadError
      if Rails.env.production?
        abort "Faker gem is not available in production. To use fake data in production, set ALLOW_FAKE_DATA=true and rebuild the Docker image."
      else
        abort "Faker gem is not available. Please run 'bundle install' to install required gems."
      end
    end

    Faker::Config.locale = "en-CA"

    facility_ids = Facility.all.ids

    20.times.each do |n|
      created_at = rand(90).days.ago
      uuid = SecureRandom.hex
      session_id = SecureRandom.hex

      visit = Analytics::Visit.create_with(created_at: created_at)
        .find_or_create_by!(uuid: uuid,
                            session_id: session_id)
      created_at = visit.created_at

      rand(1..5).times.each do
        event_date = rand(120).minutes.after(created_at)
        event = visit.events.create!(controller_name: 'api/facilities',
                                     action_name: 'index',
                                     lat: Faker::Address.latitude,
                                     long: Faker::Address.longitude,
                                     request_url: '/api/facilities',
                                     request_ip: Faker::Internet.ip_v4_address,
                                     request_params: { search: 'a search text'},
                                     created_at: event_date)


        n = rand(1..10)
        ids_to_filter = facility_ids.sample(n)
        Facility.where(id: ids_to_filter).find_each do |facility|
          event.impressions.create!(impressionable: facility,
                                    created_at: event_date)
        end
      end

      print "."
    end
  end
end
