class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.references :visit, null: false, index: true
      t.string :controller_name, null: false
      t.string :action_name, null: false
      t.decimal :lat
      t.decimal :long
      t.string :ip_address

      t.timestamps
    end
  end
end
