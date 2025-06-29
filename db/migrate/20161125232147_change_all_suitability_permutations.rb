class ChangeAllSuitabilityPermutations < ActiveRecord::Migration[4.2]
  # Define a local model class that only knows about existing columns
  class MigrationFacility < ActiveRecord::Base
    self.table_name = 'facilities'
  end

  def up
    change_column :facilities, :suitability, :string
    MigrationFacility.find_each do |f|
      f.update_column(:suitability, f.suitability.downcase)
    end
  end
end
