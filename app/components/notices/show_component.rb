# frozen_string_literal: true

class Notices::ShowComponent < ViewComponent::Base
  attr_reader :notice

  def initialize(notice:)
    super()

    @notice = notice
  end

  def notice_dom_id
    dom_id(notice)
  end
end
