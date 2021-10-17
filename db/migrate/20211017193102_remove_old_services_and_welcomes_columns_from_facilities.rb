class RemoveOldServicesAndWelcomesColumnsFromFacilities < ActiveRecord::Migration[6.1]
  def change
    remove_columns :facilities, :welcomes, :services
  end
end
