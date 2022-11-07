class DropAnaylitics < ActiveRecord::Migration[7.0]
  def change
    drop_table :anaylitics
  end
end
