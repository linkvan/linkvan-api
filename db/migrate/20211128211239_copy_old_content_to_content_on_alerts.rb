class CopyOldContentToContentOnAlerts < ActiveRecord::Migration[6.1]
  def change
    # Alert.with_rich_text_content.each do |alert|
    # Alert.all.each do |alert|
    Alert.where.not(old_content: nil).each do |alert|
      # alert.old_content = alert.content.to_s
      alert.content = alert.old_content
      alert.save!(validate: false)
    end
  end
end
