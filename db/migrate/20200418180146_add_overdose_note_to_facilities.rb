class AddOverdoseNoteToFacilities < ActiveRecord::Migration[4.2]
  def change
    add_column :facilities, :overdose_note, :text
  end
end
