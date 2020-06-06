class AddFieldsToStatuses < ActiveRecord::Migration[4.2]
  def change
    add_column :statuses, :fid, :integer
    add_column :statuses, :changetype, :string
  end
end
