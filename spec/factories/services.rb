FactoryBot.define do
  factory :service do
    sequence(:name, "aa") { |n| "service_#{n}" }
    key { name.parameterize.underscore }
  end
end
