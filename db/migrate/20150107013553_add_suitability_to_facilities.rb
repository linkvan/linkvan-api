class AddSuitabilityToFacilities < ActiveRecord::Migration[4.2]
  def change
    add_column :facilities, :suitability, :string
  end
end
