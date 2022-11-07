class RenameListedOptionsToOldListedOptions < ActiveRecord::Migration[7.0]
  def change
    rename_table :listed_options, :old_listed_options
  end
end
