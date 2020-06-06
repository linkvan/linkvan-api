class CreateAnaylitics < ActiveRecord::Migration[4.2]
  def change
    create_table :anaylitics do |t|
      t.decimal :lat
      t.decimal :long

      t.timestamps
    end
  end
end
