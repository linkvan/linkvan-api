require 'rake'

namespace :json do
  # Usage Example:
  #    rake json:export[./db/facilities.json]
  desc "export active facilities to a JSON file"
  task :export, [:jsonfile] => [:environment] do |_t, args|
    facilities_hash = {
      v1: { facilities: Facility.is_verified.as_json }
    }
    File.open(args[:jsonfile], "w") do |f|
      f.write JSON.pretty_generate(facilities_hash)
    end
  end #/export

  # Usage Example:
  #    rake json:import[./db/facilities.json]
  desc "import active facilities to a JSON file"
  task :import, [:jsonfile] => :environment do |_t, args|
    raise "ERROR: This rake task is supposed to be used only by developers." if Rails.env.production?

    file = File.open args[:jsonfile]
    data = JSON.load file
    file.close

    # expected structure:
    #   { 'v1': {'facilities': [
    #       {<facility_attributes},
    #       {<facility_attributes} ]
    #   }}
    facilities = data.dig('v1', 'facilities')
    facilities.each do |facility_data|
      Facility.create(facility_data)
    end
  end
end #/json
