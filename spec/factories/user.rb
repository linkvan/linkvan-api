FactoryBot.define do
  factory :user do
    sequence(:name, "aa") { |n| "User Name #{n}" }
    email { "#{name.to_s.downcase.split.join('_')}@example.com" }
    admin { false }
    password { 'password' }
    password_confirmation { 'password' }

    factory :admin_user, traits: %i[admin verified]

    trait :admin do
      admin { true }
    end

    trait :verified do
      verified { true }
    end

    trait :not_verified do
      verified { false }
    end
  end
end
