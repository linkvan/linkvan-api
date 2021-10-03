FactoryBot.define do
  factory :facility_schedule do
    week_day { :monday }

    facility factory: :facility
  end
end
