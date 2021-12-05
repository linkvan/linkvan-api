class RemoveOldContentFromNotices < ActiveRecord::Migration[6.1]
  def change
    remove_column :notices, :old_content
  end
end
