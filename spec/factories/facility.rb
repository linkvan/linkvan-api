FactoryBot.define do
  factory :facility do
    id { 1 }
    name { "Test Facility" }
    lat { 49.2450424 }
    long { -123.02894679999997 }
    address { "address of facility" }
    phone { "123" }
    website { "www.facility.test" }
    description { "description of the facility" }
    notes { "small notes about facility" }
    verified { true }


    # Facility is open all day
    factory :open_all_day_facility do
    end

    # Facility is closed all day
    factory :close_all_day_facility do
    end

    # Facility is open and has time set.
    factory :open_facility do

      # Facility has two times set for the same day.
      factory :open2_facility do

      end
    end

    # Facility is closed and has time set.
    factory :close_facility do
    end
  end

  # Remove these fields
  # "r_pets": false,
  # "r_id": false,
  # "r_cart": false,
  # "r_phone": false,
  # "r_wifi": false,
end
