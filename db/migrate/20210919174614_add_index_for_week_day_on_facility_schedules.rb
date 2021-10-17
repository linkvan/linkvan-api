class AddIndexForWeekDayOnFacilitySchedules < ActiveRecord::Migration[6.1]
  def change
    add_index :facility_schedules, %i[facility_id week_day], unique: true
  end
end
