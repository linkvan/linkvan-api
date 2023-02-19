class AddEventAndImpressionableUkToImpressions < ActiveRecord::Migration[7.0]
  def change
    add_index :impressions, %i[event_id impressionable_type impressionable_id],
                            name: 'uk_index_impressions_on_event_and_impressionable',
                            unique: true
  end
end
