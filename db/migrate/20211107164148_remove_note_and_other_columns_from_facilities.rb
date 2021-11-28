class RemoveNoteAndOtherColumnsFromFacilities < ActiveRecord::Migration[6.1]
  def change
    remove_column :facilities, :r_pets, :boolean, default: false
    remove_column :facilities, :r_id, :boolean, default: false
    remove_column :facilities, :r_cart, :boolean, default: false
    remove_column :facilities, :r_phone, :boolean, default: false
    remove_column :facilities, :r_wifi, :boolean, default: false

    remove_column :facilities, :shelter_note, :text
    remove_column :facilities, :food_note, :text
    remove_column :facilities, :medical_note, :text
    remove_column :facilities, :hygiene_note, :text
    remove_column :facilities, :technology_note, :text
    remove_column :facilities, :legal_note, :text
    remove_column :facilities, :learning_note, :text
    remove_column :facilities, :overdose_note, :text

  end
end
