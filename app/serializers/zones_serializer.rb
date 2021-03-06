# frozen_string_literal: true

class ZonesSerializer < ApplicationCollectionSerializer
  def as_json(response = nil)
    result = super(response)
    zones = serialize(serializer_class || ZoneSerializer)
    result.merge({ zones: zones })
  end
end # /ZoneSerializer
