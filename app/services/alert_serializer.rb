# frozen_string_literal: true

class AlertSerializer < ApplicationService
  include Serializable

  def initialize(alert)
    super()

    @alert = alert
  end

  def call
    data = nil

    if @alert.present?
      data = hashify(@alert, Alert.attribute_names)
      data[:content] = @alert.content_html
    end

    Result.new(data: data&.symbolize_keys)
  end
end
