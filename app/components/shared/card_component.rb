# frozen_string_literal: true

class Shared::CardComponent < ViewComponent::Base
  # include ActionView::RecordIdentifier

  renders_one :action_content
  renders_one :footer
  renders_many :buttons, "ButtonComponent"

  attr_reader :card_id

  def initialize(title:, card_id: nil, options: {})
    super()

    @card_id = card_id
    @title = title
    @header_classes = options.dig(:header, :classes)
  end

  def header_component
    HeaderComponent.new title: @title, classes: @header_classes, buttons: buttons
  end

  class HeaderComponent < ViewComponent::Base
    attr_reader :title

    def initialize(title:, classes:, buttons: nil)
      super()

      @title = title
      @classes = classes
      @buttons = buttons.presence || []
    end

    private

    def classes
      "card-header level #{@classes}"
    end
  end

  class ButtonComponent < ViewComponent::Base
    def initialize(title:, path:, method: :get, icon_class: "fa-pen")
      super()

      @title = title
      @path = path
      @method = method
      @icon_class = icon_class
    end

    def render?
      @title.present? && @path.present?
    end

    def call
      params = { class: "button" }
      params[:method] = @method if @method.present? && @method != :get

      link_to @path, params do
        button_content
      end
    end

    def button_content
      edit_icon + tag.span(@title)
    end

    def edit_icon
      tag.span(class: "icon") do
        tag.i class: "fas #{@icon_class}"
      end
    end
  end
end
