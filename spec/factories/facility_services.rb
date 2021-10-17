FactoryBot.define do
  factory :facility_service do
    facility factory: :facility
    service factory: :service
    note { "MyText" }
  end
end
