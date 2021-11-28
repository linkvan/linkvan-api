# frozen_string_literal: true

class Alerts::ShowComponent < ViewComponent::Base
  attr_reader :alert

  def initialize(alert:)
    super()

    @alert = alert
  end

  def alert_dom_id
    dom_id(alert)
  end
end
