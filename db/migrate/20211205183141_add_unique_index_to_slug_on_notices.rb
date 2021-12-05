class AddUniqueIndexToSlugOnNotices < ActiveRecord::Migration[6.1]
  def change
    add_index :notices, :slug, unique: true
  end
end
