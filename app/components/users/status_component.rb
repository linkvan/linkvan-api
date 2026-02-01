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

  private

  # Overrides superclass
  def title
    @status.to_s.titleize
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
