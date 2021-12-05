class CopyOldControlToContentOnNotices < ActiveRecord::Migration[6.1]
  def up
    Notice.where.not(old_content: nil).each do |notice|
      notice.content = notice.old_content
      notice.save!(validate: false)
    end
  end

  def down
    Notice.with_rich_text_content.each do |notice|
      notice.old_content = notice.content.to_s
      notice.save!(validate: false)
    end
  end
end
