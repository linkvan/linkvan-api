class AddStartsEndsToFacilities < ActiveRecord::Migration[4.2]
  def change
    add_column :facilities, :startstues_at, :datetime
    add_column :facilities, :endstues_at, :datetime
    add_column :facilities, :startswed_at, :datetime
    add_column :facilities, :endswed_at, :datetime
    add_column :facilities, :startsthurs_at, :datetime
    add_column :facilities, :endsthurs_at, :datetime
    add_column :facilities, :startsfri_at, :datetime
    add_column :facilities, :endsfri_at, :datetime
    add_column :facilities, :startssat_at, :datetime
    add_column :facilities, :endssat_at, :datetime
    add_column :facilities, :startssun_at, :datetime
    add_column :facilities, :endssun_at, :datetime
  end
end
