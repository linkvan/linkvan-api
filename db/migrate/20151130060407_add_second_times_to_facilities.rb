class AddSecondTimesToFacilities < ActiveRecord::Migration[4.2]
  def change
    add_column :facilities, :second_time_tues, :boolean, :default => false
    add_column :facilities, :second_time_wed, :boolean, :default => false
    add_column :facilities, :second_time_thurs, :boolean, :default => false
    add_column :facilities, :second_time_fri, :boolean, :default => false
    add_column :facilities, :second_time_sat, :boolean, :default => false
    add_column :facilities, :second_time_sun, :boolean, :default => false
  end
end