class AddSuitabilityToWelcomes < ActiveRecord::Migration[4.2]
  class MigrationFacility < ActiveRecord::Base
    self.table_name = 'facilities'
  end

  def change
    change_column :facilities, :welcomes, :string
    MigrationFacility.find_each do |f|
      f.welcomes = f.welcomes.concat(" " + f.suitability)
      f.save
    end
  end
end
