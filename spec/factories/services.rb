FactoryBot.define do
  factory :service do
    sequence(:name, "aa") { |n| "service_#{n}" }
  end
end
