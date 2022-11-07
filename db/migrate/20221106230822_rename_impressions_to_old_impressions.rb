class RenameImpressionsToOldImpressions < ActiveRecord::Migration[7.0]
  def change
    rename_table :impressions, :old_impressions
  end
end
