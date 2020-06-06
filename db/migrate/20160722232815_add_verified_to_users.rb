class AddVerifiedToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :verified, :boolean, default: false
  end
end
