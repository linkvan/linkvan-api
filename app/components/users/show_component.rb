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
end
