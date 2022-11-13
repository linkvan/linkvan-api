class RenameAnalyticsToOldAnalytics < ActiveRecord::Migration[7.0]
  def change
    rename_table :analytics, :old_analytics
  end
end
