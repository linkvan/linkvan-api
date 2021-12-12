# frozen_string_literal: true

class Layout::FooterComponent < ViewComponent::Base
  delegate :current_user, to: :helpers
end
