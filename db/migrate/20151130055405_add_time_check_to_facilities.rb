class AddTimeCheckToFacilities < ActiveRecord::Migration[4.2]
  def change
    add_column :facilities, :second_time, :boolean, :default => false
  end
end
