FactoryBot.define do
  factory :message do
    name { "John Doe" }
    phone { "123-456-7890" }
    content { "This is a test message content." }
  end
end
