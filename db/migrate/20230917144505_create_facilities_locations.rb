class CreateFacilitiesLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :facility_locations do |t|
      t.references :facility, null: false, foreign_key: true
      t.string :address, null: false
      t.string :city, null: false
      t.decimal :latitude
      t.decimal :longitude
      t.datetime :active_at
      t.text :data_raw

      t.timestamps
    end
  end
end
