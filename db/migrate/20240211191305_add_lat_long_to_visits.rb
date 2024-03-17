class AddLatLongToVisits < ActiveRecord::Migration[7.0]
  def change
    change_table :visits do |t|
      t.decimal :lat
      t.decimal :long
    end
  end
end
