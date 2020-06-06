class ChangeFacilitySuitability < ActiveRecord::Migration[4.2]
  def up
    change_column :facilities, :suitability, :string
    Facility.find_each do |f|
      if f.suitability == "Children"
        f.suitability = "children"
        f.save
      end
    end
  end

  def down
    change_column :facilities, :suitability, :string
    Facility.find_each do |f|
      if f.suitability == "children"
        f.suitability = "Children"
        f.save
      end
    end
  end
end
