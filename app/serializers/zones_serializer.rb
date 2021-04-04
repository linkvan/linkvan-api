# frozen_string_literal: true

class ZonesSerializer < ApplicationCollectionSerializer
  def as_json(response = nil)
    result = super(response)
    zones = build
    result.merge({ zones: zones })
  end

  def build
    serialize(serializer_class || ZoneSerializer)
  end
end
