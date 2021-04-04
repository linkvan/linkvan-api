# frozen_string_literal: true

class AlertsSerializer < ApplicationCollectionSerializer
  def as_json(response = nil)
    result = super(response)
    alerts = build
    result.merge({ alerts: alerts })
  end

  def build
    serialize(serializer_class || AlertSerializer)
  end
end
