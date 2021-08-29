# frozen_string_literal: true

class Shared::CardComponent < ViewComponent::Base
  # include ActionView::RecordIdentifier

  renders_one :footer
  # renders_many :buttons
  renders_many :buttons, 'ButtonComponent'
  # renders_many :buttons, ->(**args) {
    # Rails.logger.info "BUTTON: #{args.inspect}"
    # header_component.button(args)
  # }

  attr_reader :card_id

  def initialize(title:, card_id: nil, options: {})
    @card_id = card_id
    @title = title
    @header_classes = options.dig(:header, :classes)
  end

  # delegate :action_content, to: :header_component

  def header_component
    # @header_component ||= HeaderComponent.new title: @title, classes: @header_classes
    HeaderComponent.new title: @title, classes: @header_classes, buttons: buttons
  end

  class HeaderComponent < ViewComponent::Base
    attr_reader :title, :classes

    def initialize(title:, classes:, buttons: nil)
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
    def initialize(title:, path:)
      @title = title
      @path = path
    end

    def render?
      @title.present? && @path.present?
    end

    def call
      link_to @path, class: "button" do
        button_content
      end
    end

    def button_content
      edit_icon + tag.span(@title)
    end

    def edit_icon
      tag.span(class: "icon") do
        tag.i class: "fas fa-pen"
      end
    end
  end
end