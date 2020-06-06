class AddAnalytics < ActiveRecord::Migration[4.2]
  def up
    create_table :analytics do |t|
      t.string :sessionID
      t.datetime :time
      t.string :cookieID, :default => nil
      t.string :service, :null => false
      t.decimal :lat, :null => false
      t.decimal :long, :null => false
      t.string :facility, :default => nil
      t.boolean :dirClicked, :default => false
      t.string :dirType, :default => nil
    end

    create_table :listedOptions do |t|
      t.belongs_to :analytic, index: true
      t.string :sessionID, :null => false
      t.datetime :time, :null => false
      t.string :facility, :null => false
      t.decimal :position, :null => false
      t.decimal :total, :null => false
    end
  end

  def down
    drop_table :listedOptions
    drop_table :analytics
  end
end
