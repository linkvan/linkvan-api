class CreateFacilityWelcome < ActiveRecord::Migration[6.1]
  def change
    create_table :facility_welcomes do |t|
      t.references :facility, null: false, foreign_key: true
      t.string :customer, null: false

      t.timestamps
    end

    add_index :facility_welcomes, [:facility_id, :customer], unique: true
  end
end
