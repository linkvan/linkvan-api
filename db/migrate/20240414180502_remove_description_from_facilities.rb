class RemoveDescriptionFromFacilities < ActiveRecord::Migration[7.0]
  def change
    remove_column :facilities, :description, :text
  end
end
