class CreateZones < ActiveRecord::Migration[4.2]
  def change
    create_table :zones do |t|
      t.string :name, null:false
      t.text :description

      t.timestamps null: false
    end
  end
end
