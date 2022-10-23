FactoryBot.define do
  factory :facility_welcome do
    facility factory: :facility

    customer { :male }
  end
end
