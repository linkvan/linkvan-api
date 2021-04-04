class FacilitiesSerializer < ApplicationCollectionSerializer
  def as_json(response = nil)
    result = super(response)
    facilities = build
    result.merge({ facilities: facilities })
  end

  def build
    serialize(serializer_class || FacilitySerializer)
  end
end # /FacilitiesSerializer
