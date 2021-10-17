class CreateFacilityTimeSlots < ActiveRecord::Migration[6.1]
  def change
    create_table :facility_time_slots do |t|
      t.references :facility_schedule, index: true

      t.integer :from_hour, null: false
      t.integer :from_min, null: false
      t.integer :to_hour, null: false
      t.integer :to_min, null: false

      t.timestamps
    end
  end
end
