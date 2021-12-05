class Notices::TableComponent < ViewComponent::Base
  attr_reader :notices

  def initialize(notices:)
    super()

    @notices = notices
  end

  class NoticeRowComponent < ViewComponent::Base
    attr_reader :notice, :table_component

    def initialize(notice, table_component:)
      super()

      @notice = notice
      @table_component = table_component
    end

    def more_menu_component
      @more_menu_component ||= MoreMenuComponent.new(notice: notice)
    end
  end

  class MoreMenuComponent < ViewComponent::Base
    attr_reader :notice

    def initialize(notice: nil)
      super()

      @notice = notice
    end
  end
end
