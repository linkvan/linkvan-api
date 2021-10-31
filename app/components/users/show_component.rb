# frozen_string_literal: true

class Users::ShowComponent < ViewComponent::Base
  attr_reader :user

  def initialize(user:)
    super()

    @user = user
  end

  def card_id
    dom_id(user)
  end

  def status_icon
    tag.span class: status_icon_span_class do
      tag.i title: status_title, class: status_icon_class
    end
  end

  def status_title
    # user.status.to_s.titleize
    if user.verified?
      tag.span "Verified", class: "tag is-light"
    else
      tag.span "Not Verified", class: "tag is-danger"
    end
  end

  def status_icon_class
    if user.verified?
      "fas fa-user-check"
    else
      "fas fa-user-times"
    end
  end

  def status_icon_span_class
    return "icon is-small"

    if user.verified?
      "icon has-text-success"
    else
      "icon has-text-danger"
    end
  end
end
