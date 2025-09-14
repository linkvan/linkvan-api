# frozen_string_literal: true

class Facilities::WelcomesIconComponent < ViewComponent::Base
  ERROR_ICON = "error.svg"
  ICONS = {
    female: "female.svg",
    male: "male.svg",
    transgender: "transgender.svg",
    children: "age-children.svg",
    youth: "age-youth.svg",
    adult: "age-adults.svg",
    senior: "age-seniors.svg"
  }.freeze

  attr_reader :variant

  def initialize(welcomes, variant: :full)
    super()

    Rails.logger.debug { "ICON: #{welcomes} => #{icon_location}" }

    @variant = variant
    @welcomes = welcomes.to_s.underscore.to_sym
  end

  def call
    return call_icon if variant == :icon

    tag.div class: "svg-icon ml-1" do
      helpers.inline_svg_tag(icon_location, size: "20px")
    end
  end

  def call_icon
    tag.span class: "icon" do
      helpers.inline_svg_tag(icon_location, size: "20px")
    end
  end

  def icon_location
    selected_icon = ICONS[@welcomes].presence || ERROR_ICON
    "icons/#{selected_icon}"
  end
end
