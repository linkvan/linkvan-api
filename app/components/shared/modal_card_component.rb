# frozen_string_literal: true

class Shared::ModalCardComponent < ViewComponent::Base
  renders_many :action_buttons, "ActionButtonComponent"

  attr_reader :id

  def initialize(id: nil)
    super()

    @id = id
  end

  class ActionButtonComponent < ViewComponent::Base
    def call
      content
    end
  end
end
