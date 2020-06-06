class CreateFacilities < ActiveRecord::Migration[4.2]
  def change
    create_table :facilities do |t|
      t.string :name
      t.string :welcomes
      t.string :services
      t.decimal :lat
      t.decimal :long
      t.string :address
      t.string :phone
      t.string :website
      t.text :description
      t.text :hours
      t.text :notes

      t.timestamps
    end
  end
end
