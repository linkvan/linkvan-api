class CreateFacilitiesLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :facilities_locations do |t|
      t.references :facility, null: false, index: true
      t.string :address, null: false
      t.string :city, null: false
      t.decimal :latitude
      t.decimal :longitude
      t.text :data_raw

      t.timestamps
    end
  end
end
