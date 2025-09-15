# frozen_string_literal: true

namespace :fake_data do
  desc "Create Facilities fake data to help development"
  task users: :environment do
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

    verified_sample = ([true] * 5) + [false]
    5.times.each do
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
