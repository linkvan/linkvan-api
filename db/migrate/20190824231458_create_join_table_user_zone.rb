class CreateJoinTableUserZone < ActiveRecord::Migration[4.2]
  def change
    create_join_table :users, :zones do |t|
      t.index [:user_id, :zone_id]
      t.index [:zone_id, :user_id]
    end
  end
end
