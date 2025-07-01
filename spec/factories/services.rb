FactoryBot.define do
  factory :service do
    sequence(:name, "aa") { |n| "service_#{n}" }
    key { name.parameterize.underscore }
  
    factory :water_fountain_service do
      name { "Water Fountain" }
      key { "water_fountain" }
    end
  end
end
