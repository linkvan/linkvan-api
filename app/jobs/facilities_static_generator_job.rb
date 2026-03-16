# frozen_string_literal: true

class FacilitiesStaticGeneratorJob
  def perform
    jsonfile = "public/facilities.json"
    facilities_hash = {
      v1: { facilities: Facility.is_verified.as_json }
    }
    File.write(jsonfile, JSON.pretty_generate(facilities_hash))
  end
end
