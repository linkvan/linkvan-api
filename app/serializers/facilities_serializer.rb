class FacilitiesSerializer < ApplicationCollectionSerializer
  def as_json(response = nil)
    result = super(response)
    facilities = serialize(serializer_class || FacilitySerializer)
    result.merge({ facilities: facilities })
  end
end #/FacilitiesSerializer
