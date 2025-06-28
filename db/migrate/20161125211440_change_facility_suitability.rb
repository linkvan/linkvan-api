class ChangeFacilitySuitability < ActiveRecord::Migration[4.2]
  # Define a local model class that only knows about existing columns
  class MigrationFacility < ActiveRecord::Base
    self.table_name = 'facilities'
  end

  def up
    change_column :facilities, :suitability, :string
    MigrationFacility.where(suitability: "Children").update_all(suitability: "children")
  end

  def down
    change_column :facilities, :suitability, :string
    MigrationFacility.where(suitability: "children").update_all(suitability: "Children")
  end
end
