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


  def initialize(welcomes)
    Rails.logger.debug "ICON: #{welcomes} => #{icon}"

    @welcomes = welcomes.to_s.underscore.to_sym
  end

  def call
    tag.span "Error: #{@welcomes}", class: "tag is-danger"

    tag.div class: "svg-icon ml-1" do
      inline_svg_tag(icon, size: "20px")
    end
  end

  def icon
    "icons/#{ICONS[@welcomes]}"
  end
end
