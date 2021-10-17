# frozen_string_literal: true

class Shared::StatusComponent < ViewComponent::Base
  STATUS_CLASSES = {
    on: "fa-check-circle has-text-success",
    off: "fa-times-circle has-text-danger"
  }.freeze

  SIZE_CLASSES = {
    large: "fa-lg"
  }.freeze

  def initialize(status, show_title: false, size: :large)
    super()

    @status = ActiveModel::Type::Boolean.new.cast(status)
    @show_title = show_title
    @size = size
  end

  def call
    @show_title.present? ? call_title : call_icon
  end

  def call_icon
    tag.span class: "icon" do
      tag.i class: "fas #{size_classes} #{status_classes}"
    end
  end

  def call_title
    tag.span class: "icon-text has-text" do
      call_icon + tag.span(title)
    end
  end

  private

  def size_classes
    SIZE_CLASSES[@size]
  end

  def title
    @status ? "Yes" : "No"
  end

  def status_classes
    STATUS_CLASSES[status]
  end

  def status
    @status ? :on : :off
  end
end
