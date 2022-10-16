# frozen_string_literal: true

class Facilities::StatusComponent < ViewComponent::Base
  attr_reader :status

  def initialize(status)
    super()

    @status = status.to_s.to_sym
  end

  def call
    case status
    when :live
      icon_span_class = "icon has-text-success"
      icon_class = "fas fa-check-square"
    when :pending_reviews
      icon_class = "fas fa-times"
      icon_span_class = "icon has-text-danger"
    when :discarded
      icon_class = "fas fa-minus-circle"
      icon_span_class = "icon has-text-warning"
    else
      icon_class = "fas"
      icon_span_class = "icon"
    end

    tag.span class: icon_span_class do
      tag.i title: title, class: icon_class
    end
  end

  def call_title_only
    title
  end

  private

  def title
    status.to_s.titleize
  end
end
