class CreateVisits < ActiveRecord::Migration[7.0]
  def change
    create_table :visits do |t|
      t.string :uuid, null: false, index: true
      t.string :session_id, null: false, index: true

      t.timestamps
    
      t.index [:uuid, :session_id], unique: true
    end
  end
end
