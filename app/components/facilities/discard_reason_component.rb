# frozen_string_literal: true

class Facilities::DiscardReasonComponent < ViewComponent::Base
  attr_reader :discard_reason

  VALID_REASONS = {
    none: "None",
    closed: "Closed",
    duplicated: "Duplicated"
  }.freeze

  def initialize(discard_reason)
    super()

    @discard_reason = discard_reason.to_sym
  end

  def self.select_options
    VALID_REASONS.invert.to_a
  end

  def call
    VALID_REASONS[discard_reason] || "Unsupported value '#{discard_reason}'"
  end
end
