class AddZoneToFacilities < ActiveRecord::Migration[4.2]
  class MigrationFacility < ActiveRecord::Base
    self.table_name = 'facilities'
  end

  def change
    add_reference :facilities, :zone, index: true, foreign_key: true

    # Create Initial Zone and add to existing facilities
    zone_name = "Vancouver"
    zone_description = "Vancouver Zone to hold previous facilities"

    reversible do |dir|
      dir.up do
        zone = Zone.create(name: zone_name, description: zone_description)
        MigrationFacility.update_all({ zone_id: zone.id })
      end

      dir.down do
        MigrationFacility.update_all({ zone_id: nil })
        zone = Zone.find_by(name: zone_name)
        zone.destroy
      end
    end
  end
end
