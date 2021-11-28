# frozen_string_literal: true

class Users::StatusComponent < Shared::StatusComponent
  STATUS_CLASSES = {
    verified: "fa-user-check",
    not_verified: "fa-user-times"
  }.freeze

  COLOR_CLASSES = {
    verified: "has-text-info-dark",
    not_verified: "has-text-danger-dark"
  }.freeze

  SIZE_CLASSES = {
    large: "fa-lg"
  }.freeze

  attr_reader :user

  def initialize(user, show_title: false, size: :large)
    super(nil, show_title: show_title, size: size)

    @user = user
    # # Overrides status from superclass
    @status = user.verified? ? :verified : :not_verified
  end

  # def call
    # @show_title.present? ? call_title : call_icon
  # end
# 
  # def call_icon
    # tag.span class: "icon" do
      # tag.i class: "fas #{size_classes} #{status_classes}"
    # end
  # end
# 
  # def call_title
    # tag.span class: "icon-text has-text" do
      # call_icon + tag.span(title)
    # end
  # end

  private

  # def size_classes
    # SIZE_CLASSES[@size]
  # end

  # Overrides superclass
  def title
    @status.to_s.titleize
    # @status ? "Yes" : "No"
  end

  def status_classes
    STATUS_CLASSES[status]
  end

  def color_classes
    COLOR_CLASSES[status]
  end

  def status
    user.verified? ? :verified : :not_verified
  end
end
