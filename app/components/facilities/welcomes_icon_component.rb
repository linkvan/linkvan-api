# frozen_string_literal: true

class Facilities::WelcomesIconComponent < ViewComponent::Base
  ICONS = {
    female: 'female.svg',
    male: 'male.svg',
    transgender: 'transgender.svg',
    children: 'age-children.svg',
    youth: 'age-youth.svg',
    adult: 'age-adults.svg',
    senior: 'age-seniors.svg'
  }.freeze


  def initialize(welcomes, show_title: false)
    Rails.logger.debug "ICON: #{welcomes} => #{icon_location}"

    @welcomes = welcomes.to_s.underscore.to_sym
  end

  def call
    tag.span "Error: #{@welcomes}", class: "tag is-danger"

    tag.div class: "svg-icon ml-1" do
      inline_svg_tag(icon_location, size: "20px")
    end
  end

  # to use this variant:
  # - render Facilities::WelcomesIconComponent.new(welcome).with_variant(:icon)
  def call_icon
    tag.span class: 'icon' do
      inline_svg_tag(icon_location, size: "20px")
    end
  end

  def icon_location
    "icons/#{ICONS[@welcomes]}"
  end

  private


end
