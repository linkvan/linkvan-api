class CreateFacilitySchedule < ActiveRecord::Migration[6.1]
  def change
    create_table :facility_schedules do |t|
      t.references :facility, index: true

      t.string :week_day, null: false
      t.boolean :open_all_day, null: false, default: false
      t.boolean :closed_all_day, null: false, default: false

      t.timestamps
    end
  end
end
