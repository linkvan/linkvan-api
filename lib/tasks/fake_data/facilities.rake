# frozen_string_literal: true

namespace :fake_data do
  desc "Create Facilities fake data to help development"
  task facilities: :environment do
    abort "This script can only be run on development environment" unless Rails.env.development?

    Faker::Config.locale = "en-CA"

    vancouver = Zone.where(name: "Vancouver").to_a
    new_west = Zone.where(name: "New Westminster").to_a
    zones = (vancouver * 2) + new_west + [nil]
    all_services = Service.all.to_a
    valid_statuses = %i[open close set_times]

    selected_users = User.verified.where.not(id: User.super_admins).to_a + [nil]

    100.times do
      ActiveRecord::Base.transaction do
        params = {}
        params[:name] = [Faker::Company.name, Faker::Company.suffix].join(" ")
        params[:address] = Faker::Address.full_address
        params[:lat] = Faker::Address.latitude
        params[:long] = Faker::Address.longitude
        params[:phone] = Faker::PhoneNumber.cell_phone
        params[:website] = Faker::Internet.url(path: "")
        params[:description] = Faker::Lorem.paragraph
        params[:notes] = Faker::Lorem.paragraphs.join("\n\n")
        params[:verified] = (rand > 0.4)
        params[:zone] = zones.sample
        params[:user] = selected_users.sample

        facility = Facility.create!(params)

        # build Welcomes
        all_customers = FacilityWelcome.customers.values
        qty_welcomes = rand(1..all_customers.count)
        selected_customers = all_customers.sample(qty_welcomes)
        selected_customers.each do |customer|
          facility.facility_welcomes.create!(customer: customer)
        end

        # build Services
        qty_services = rand(1..all_services.count)
        selected_services = all_services.sample(qty_services)
        selected_services.each do |service|
          facility.facility_services.create!(service: service, note: Faker::Lorem.paragraph)
        end

        # build schedule
        FacilitySchedule.week_days.values.each do |wday|
          status = valid_statuses.sample
          schedule_params = {}
          schedule_params[:week_day] = wday
          schedule_params[:open_all_day] = (status == :open)
          schedule_params[:closed_all_day] = (status == :close)

          schedule = facility.schedules.create!(schedule_params)

          next unless status == :set_times

          # create TimeSlots
          qty_time_slots = (1..2).to_a.sample
          qty_time_slots.times.each do |n|
            if qty_time_slots == 1
              start_time = 9
              end_time = 17
            elsif n == 1
              start_time = 9
              end_time = 12
            else
              start_time = 14
              end_time = 18
            end

            schedule.time_slots.create!(from_hour: start_time, from_min: 0, to_hour: end_time, to_min: 0)
          end
        end
      end
      print "."
    end

    puts "\ndone"
  end
end
