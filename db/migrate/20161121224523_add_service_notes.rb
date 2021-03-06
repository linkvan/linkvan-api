class AddServiceNotes < ActiveRecord::Migration[4.2]
  def up
    add_column :facilities, :shelter_note, :text
    add_column :facilities, :food_note, :text
    add_column :facilities, :medical_note, :text
    add_column :facilities, :hygiene_note, :text
    add_column :facilities, :technology_note, :text
    add_column :facilities, :legal_note, :text
    add_column :facilities, :learning_note, :text
  end

  def down
    remove_column :facilities, :shelter_note
    remove_column :facilities, :food_note
    remove_column :facilities, :medical_note
    remove_column :facilities, :hygiene_note
    remove_column :facilities, :technology_note
    remove_column :facilities, :legal_note
    remove_column :facilities, :learning_note
  end
end
