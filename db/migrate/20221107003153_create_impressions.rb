class CreateImpressions < ActiveRecord::Migration[7.0]
  def change
    create_table :impressions do |t|
      t.references :event, null: false, index: true
      t.references :impressionable, polymorphic: true, null: false, index: true

      t.timestamps
    end
  end
end
