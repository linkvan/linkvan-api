class RenameContentToOldContentOnAlerts < ActiveRecord::Migration[6.1]
  def change
    rename_column :alerts, :content, :old_content
  end
end
