class AddMoreTimesToFacilities < ActiveRecord::Migration[4.2]
  def change
    add_column :facilities, :startsmon_at2, :time
    add_column :facilities, :endsmon_at2, :time
    add_column :facilities, :startstues_at2, :time
    add_column :facilities, :endstues_at2, :time
    add_column :facilities, :startswed_at2, :time
    add_column :facilities, :endswed_at2, :time
    add_column :facilities, :startsthurs_at2, :time
    add_column :facilities, :endsthurs_at2, :time
    add_column :facilities, :startsfri_at2, :time
    add_column :facilities, :endsfri_at2, :time
    add_column :facilities, :startssat_at2, :time
    add_column :facilities, :endssat_at2, :time
    add_column :facilities, :startssun_at2, :time
    add_column :facilities, :endssun_at2, :time
    add_column :facilities, :open_all_day_mon, :boolean
    add_column :facilities, :open_all_day_tues, :boolean
    add_column :facilities, :open_all_day_wed, :boolean
    add_column :facilities, :open_all_day_thurs, :boolean
    add_column :facilities, :open_all_day_fri, :boolean
    add_column :facilities, :open_all_day_sat, :boolean
    add_column :facilities, :open_all_day_sun, :boolean
    add_column :facilities, :closed_all_day_mon, :boolean
    add_column :facilities, :closed_all_day_tues, :boolean
    add_column :facilities, :closed_all_day_wed, :boolean
    add_column :facilities, :closed_all_day_thurs, :boolean
    add_column :facilities, :closed_all_day_fri, :boolean
    add_column :facilities, :closed_all_day_sat, :boolean
    add_column :facilities, :closed_all_day_sun, :boolean
  end
end
