# frozen_string_literal: true

class Layout::HeaderComponent < ViewComponent::Base
  delegate :current_user, to: :helpers
end
