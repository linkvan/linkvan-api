# frozen_string_literal: true

class Facilities::CardComponent < ViewComponent::Base
  attr_reader :facility

  def initialize(facility:)
    @facility = facility
  end
end
