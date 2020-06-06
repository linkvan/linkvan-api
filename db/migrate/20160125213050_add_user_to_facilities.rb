class AddUserToFacilities < ActiveRecord::Migration[4.2]
  def change
    add_reference :facilities, :user, index: true
  end
end
