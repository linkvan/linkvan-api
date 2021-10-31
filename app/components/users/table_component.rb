class Users::TableComponent < ViewComponent::Base
  attr_reader :users

  def initialize(users:)
    super()

    @users = users
  end

  class UserRowComponent < ViewComponent::Base
    attr_reader :user, :table_component

    def initialize(user, table_component:)
      super()

      @user = user
      @table_component = table_component
    end

    def more_menu_component
      @more_menu_component ||= MoreMenuComponent.new(user: user)
    end
  end

  class MoreMenuComponent < ViewComponent::Base
    attr_reader :user

    def initialize(user: nil)
      super()

      @user = user
    end
  end
end
