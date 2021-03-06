class AddStartsEndTimeToFacilities < ActiveRecord::Migration[4.2]
  def change
    add_column :facilities, :startsmon_at, :time
    add_column :facilities, :endsmon_at, :time
    add_column :facilities, :startstues_at, :time
    add_column :facilities, :endstues_at, :time
    add_column :facilities, :startswed_at, :time
    add_column :facilities, :endswed_at, :time
    add_column :facilities, :startsthurs_at, :time
    add_column :facilities, :endsthurs_at, :time
    add_column :facilities, :startsfri_at, :time
    add_column :facilities, :endsfri_at, :time
    add_column :facilities, :startssat_at, :time
    add_column :facilities, :endssat_at, :time
    add_column :facilities, :startssun_at, :time
    add_column :facilities, :endssun_at, :time
  end
end
