# frozen_string_literal: true

class Shared::ModalCardComponent < ViewComponent::Base
  renders_many :action_buttons, "ActionButtonComponent"

  attr_reader :id, :title

  def initialize(id: nil, title: nil)
    super()

    @id = id
    @title = title
  end

  class ActionButtonComponent < ViewComponent::Base
    def call
      content
    end
  end
end
