class AddMonToFacilities < ActiveRecord::Migration[4.2]
  def change
    add_column :facilities, :startsmon_at, :datetime
    add_column :facilities, :endsmon_at, :datetime
  end
end
