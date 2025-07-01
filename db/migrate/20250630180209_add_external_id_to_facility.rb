class AddExternalIdToFacility < ActiveRecord::Migration[7.0]
  def change
    add_column :facilities, :external_id, :string
  end
end
