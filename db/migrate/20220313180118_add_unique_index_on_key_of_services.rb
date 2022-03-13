class AddUniqueIndexOnKeyOfServices < ActiveRecord::Migration[6.1]
  def change
    add_index :services, :key, unique: true
  end
end
