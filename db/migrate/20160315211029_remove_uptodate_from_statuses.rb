class RemoveUptodateFromStatuses < ActiveRecord::Migration[4.2]
  def change
    remove_column :statuses, :uptodate, :boolean
  end
end
