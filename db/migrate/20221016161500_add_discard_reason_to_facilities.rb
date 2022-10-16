class AddDiscardReasonToFacilities < ActiveRecord::Migration[7.0]
  def change
    add_column :facilities, :discard_reason, :string, null: true, index: true
  end
end
