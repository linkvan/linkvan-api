class FacilitiesStaticGeneratorJob

    def perform
        jsonfile = 'public/facilities.json'
        facilities_hash = {
        v1: { facilities: Facility.is_verified.as_json }
        }
        File.open(jsonfile, "w") do |f|
        f.write JSON.pretty_generate( facilities_hash )
        end
    end #/perform
    
end #/FacilitiesStaticGeneratorJob