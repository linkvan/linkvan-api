class FixSecondTimeName < ActiveRecord::Migration[4.2]
  def change
    rename_column :facilities, :second_time, :second_time_mon
  end
end
