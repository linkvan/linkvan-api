FactoryBot.define do
  factory :notice do
    sequence(:title, "aa") { |n| "Notice Title #{n}" }
    content { "Content for Notice with Title - #{title}" }
    published { false }
    notice_type { :general }

    trait :published do
      published { true }
    end

    trait :draft do
      published { false }
    end
  end
end
