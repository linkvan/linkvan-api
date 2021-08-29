class ImportFacilityWelcomes < ActiveRecord::Migration[6.1]
  def up
    ActiveRecord::Base.transaction do
      available_welcomes = FacilityWelcome.customers.values

      OldFacility.all.find_each do |old_facility|
        welcomes_array = old_facility.welcomes.split(" ").map(&:strip).map(&:underscore).compact

        if welcomes_array.include?("all")
          welcomes_array.delete("all")

          welcomes_array = (welcomes_array | available_welcomes)
        end

        welcomes_array.each do |welcome_string|
          unless available_welcomes.include?(welcome_string)
            # try the singular version of the welcome customer type if validation fails
            welcome_string = welcome_string.singularize

            next unless available_welcomes.include?(welcome_string)
          end

          # Fail migration if Facility can't be found by ID.
          # An exception should never happen because the data comes the same database table
          facility = Facility.find(old_facility.id)
          facility_welcome = facility.facility_welcomes.find_by(customer: welcome_string)

          next if facility_welcome.present?

          facility.facility_welcomes.create!(customer: welcome_string)
        end
      end
    end
  end

  def down
    ActiveRecord::Base.transaction do
      Facility.all.find_each do |facility|
        old_facility = OldFacility.find(facility.id)

        facility_welcomes = facility.facility_welcomes

        facility_hash = { welcomes: facility_welcomes.map(&:name).join(" ") }

        old_facility.update!(facility_hash)
      end
    end
  end

  class OldFacility < ActiveRecord::Base
    self.table_name = "facilities"
  end
end
