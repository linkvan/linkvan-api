class AddResourcesToFacilities < ActiveRecord::Migration[4.2]
  def change
    add_column :facilities, :r_pets, :boolean, :default => false
    add_column :facilities, :r_id, :boolean, :default => false
    add_column :facilities, :r_cart, :boolean, :default => false
    add_column :facilities, :r_phone, :boolean, :default => false
    add_column :facilities, :r_wifi, :boolean, :default => false
  end
end
