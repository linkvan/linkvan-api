# frozen_string_literal: true

namespace :fake_data do
  desc "Create Analytics fake data to help development"
  task analytics: :environment do
    abort "This script can only be run on development environment" unless Rails.env.development?

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
