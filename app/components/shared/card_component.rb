# frozen_string_literal: true

class Shared::CardComponent < ViewComponent::Base
  # include ActionView::RecordIdentifier

  renders_many :action_contents
  renders_one :footer

  attr_reader :card_id

  def initialize(title:, card_id: nil, options: {})
    @card_id = card_id
    @title = title
    @header_classes = options.dig(:header, :classes)
  end

  delegate :action_content, to: :header_component

  def header
    render header_component
  end

  def header_component
    @header_component ||= HeaderComponent.new title: @title, classes: @header_classes
  end

  class HeaderComponent < ViewComponent::Base
    attr_reader :title, :classes

    renders_many :action_contents

    def initialize(title:, classes:)
      @title = title
      @classes = classes
    end

    private

    def classes
      "card-header level #{@classes}"
    end
  end
end
