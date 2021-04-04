class AddTypeToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :notice_type, :string
  end
end
