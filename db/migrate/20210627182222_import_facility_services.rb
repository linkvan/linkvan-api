class ImportFacilityServices < ActiveRecord::Migration[6.1]
  NOTE_COLUMNS = {
    shelter: "shelter_note",
    food: "food_note",
    medical: "medical_note",
    hygiene: "hygiene_note",
    tecnology: "technology_note",
    legal: "legal_note",
    learning: "learning_note",
    overdose: "overdose_note"
  }.freeze

  def up
    ActiveRecord::Base.transaction do
      OldFacility.all.find_each do |old_facility|
        services_array = old_facility.services.split(" ").map(&:strip).compact

        services_array.each do |service_string|
          note = nil

          service = Service.find_by("name ilike ?", service_string)
          # Fail migratin is Facility can't be found by ID.
          # An exception should never happen because the data comes the same database table
          facility = Facility.find(old_facility.id)

          note_column = "#{service_string.downcase}_note"
          note = old_facility.send(note_column) if old_facility.respond_to?(note_column)

          if service.present?
            # Use existing facility service if one exists.
            facility_service = facility.facility_services.find_by(service: service)
            # Otherwise, build a new facility service
            facility_service = facility.facility_services.build(service: service) if facility_service.blank?

            # Saves facility service including appropriate note.
            facility_service.note = note.to_s.strip.presence

            facility_service.save!
          end
        end
      end
      # raise "DEVELOPMENT"
    end
  end

  def down
    ActiveRecord::Base.transaction do
      Facility.all.find_each do |facility|
        old_facility = OldFacility.find(facility.id)

        facility_services = facility.facility_services
        services = facility.services

        next if services.blank?

        facility_hash = { services: services.pluck(:name).join(" ") }

        services.each do |service|
          fac_service = facility_services.find_by(service: service)
          note = fac_service&.note

          name = service.name.downcase.gsub(" ", "_")
          note_column = NOTE_COLUMNS[name.downcase.to_sym]

          facility_hash[note_column] = note if note.present?
        end

        old_facility.update!(facility_hash)
      end
    end
  end

  class OldFacility < ActiveRecord::Base
    self.table_name = "facilities"
  end
end
