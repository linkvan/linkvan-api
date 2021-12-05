class RemoveOldContentFromAlerts < ActiveRecord::Migration[6.1]
  def change
    remove_column :alerts, :old_content
  end
end
