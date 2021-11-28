class Alerts::TableComponent < ViewComponent::Base
  attr_reader :alerts

  def initialize(alerts:)
    super()

    @alerts = alerts
  end

  class AlertRowComponent < ViewComponent::Base
    attr_reader :alert, :table_component

    def initialize(alert, table_component:)
      super()

      @alert = alert
      @table_component = table_component
    end

    def more_menu_component
      @more_menu_component ||= MoreMenuComponent.new(alert: alert)
    end
  end

  class MoreMenuComponent < ViewComponent::Base
    attr_reader :alert

    def initialize(alert: nil)
      super()

      @alert = alert
    end
  end
end
