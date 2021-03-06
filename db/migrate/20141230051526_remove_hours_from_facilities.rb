class RemoveHoursFromFacilities < ActiveRecord::Migration[4.2]
  def change
    remove_column :facilities, :hours, :string
  end
end
