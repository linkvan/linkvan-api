class CopyOldContentToContentOnAlerts < ActiveRecord::Migration[6.1]
  def up
    Alert.where.not(old_content: nil).each do |alert|
      alert.content = alert.old_content
      alert.save!(validate: false)
    end
  end

  def down
    Alert.with_rich_text_content.each do |alert|
      alert.old_content = alert.content.to_s
      alert.save!(validate: false)
    end
  end
end
