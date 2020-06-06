class AddVerifedToFacilities < ActiveRecord::Migration[4.2]
  def change
    add_column :facilities, :verified, :boolean, default: false
  end
end
