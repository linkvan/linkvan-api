# frozen_string_literal: true

namespace :fake_data do
  desc "Create Facilities fake data to help development"
  task users: :environment do
    abort "This script can only be run on development environment" unless Rails.env.development?

    Faker::Config.locale = "en-CA"

    verified_sample = ([true] * 5) + [false]
    10.times.each do
      verified = verified_sample.sample

      User.create!(
        name: Faker::Name.name,
        email: Faker::Internet.email,
        password: "password",
        password_confirmation: "password",
        verified: verified,
        admin: false,
        phone_number: Faker::PhoneNumber.cell_phone,
        organization: Faker::Company.name
      )
    end
  end
end
