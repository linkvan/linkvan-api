class AddKeyToServices < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :key, :string, index: true
  end
end
