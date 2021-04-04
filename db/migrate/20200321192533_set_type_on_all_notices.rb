class SetTypeOnAllNotices < ActiveRecord::Migration[4.2]
  def change
    Notice.transaction do
      Notice.all.update_all(notice_type: :general)
    end
  end
end
