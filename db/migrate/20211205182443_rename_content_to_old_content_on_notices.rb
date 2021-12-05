class RenameContentToOldContentOnNotices < ActiveRecord::Migration[6.1]
  def change
    rename_column :notices, :content, :old_content
  end
end
