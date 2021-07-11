class CreateFacilityServices < ActiveRecord::Migration[6.1]
  def change
    create_table :facility_services do |t|
      t.references :facility, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.text :note

      t.timestamps
    end

    add_index :facility_services, [:facility_id, :service_id], unique: true
  end
end
