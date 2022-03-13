class ChangeKeyToNotNullOnServices < ActiveRecord::Migration[6.1]
  def up
    change_column :services, :key, :string, null: false
  end

  def down
    change_column :services, :key, :string, null: true
  end
end
