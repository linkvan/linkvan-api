# frozen_string_literal: true

namespace :fake_data do
  desc "Create Analytics fake data to help development"
  task analytics: :environment do
    abort "This script can only be run on development environment" unless Rails.env.development?

    Faker::Config.locale = "en-CA"

    facility_ids = Facility.all.ids

    start_date = 1.day.ago
    30.times.each do |x|
      created_at = start_date + x.days
      y = (0.2*x).ceil
      puts "Creating #{y} visits"
      x.times.each do
        uuid = SecureRandom.hex
        session_id = SecureRandom.hex
        visit = Analytics::Visit.create_with(created_at: created_at)
          .find_or_create_by!(uuid: uuid,
                              session_id: session_id)
        created_at = visit.created_at

        rand(1..4).times.each do
          event_date = rand(120).minutes.after(created_at)
          event = visit.events.create!(controller_name: 'api/facilities',
                                      action_name: 'index',
                                      lat: rand(49.260635..49.305427),
                                      long: rand(-123.176651..-123.056488),
                                      request_url: '/api/facilities',
                                      request_ip: Faker::Internet.ip_v4_address,
                                      request_params: { search: 'a search text'},
                                      created_at: event_date)


          p = rand(1..10)
          ids_to_filter = facility_ids.sample(p)
          Facility.where(id: ids_to_filter).find_each do |facility|
            event.impressions.create!(impressionable: facility,
                                      created_at: event_date)
          end
        end
      end

      print "."
    end
  end
end