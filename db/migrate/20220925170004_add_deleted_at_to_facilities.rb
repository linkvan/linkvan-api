class AddDeletedAtToFacilities < ActiveRecord::Migration[7.0]
  def change
    add_column :facilities, :deleted_at, :datetime, null: true, index: true
  end
end
