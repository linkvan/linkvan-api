# frozen_string_literal: true

class Facilities::CardComponent < ViewComponent::Base
  def initialize(facility:)
    @facility = facility
  end

  def html_class_for(type)
    case type.to_s.to_sym
    when :notice
      'is-info'
    when :alert
      'is-danger'
    else
      ''
    end
  end
end
