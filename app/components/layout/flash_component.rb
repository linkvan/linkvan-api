# frozen_string_literal: true

class Layout::FlashComponent < ViewComponent::Base
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
