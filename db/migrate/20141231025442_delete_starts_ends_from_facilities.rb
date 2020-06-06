class DeleteStartsEndsFromFacilities < ActiveRecord::Migration[4.2]
  def change
  	remove_column :facilities, :startsmon_at, :datetime
  	remove_column :facilities, :endsmon_at, :datetime
  	remove_column :facilities, :startstues_at, :datetime
  	remove_column :facilities, :endstues_at, :datetime
  	remove_column :facilities, :startswed_at, :datetime
  	remove_column :facilities, :endswed_at, :datetime
  	remove_column :facilities, :startsthurs_at, :datetime
  	remove_column :facilities, :endsthurs_at, :datetime
  	remove_column :facilities, :startsfri_at, :datetime
  	remove_column :facilities, :endsfri_at, :datetime
  	remove_column :facilities, :startssat_at, :datetime
  	remove_column :facilities, :endssat_at, :datetime
  	remove_column :facilities, :startssun_at, :datetime
  	remove_column :facilities, :endssun_at, :datetime
  end
end
