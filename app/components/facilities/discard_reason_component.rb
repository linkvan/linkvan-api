# frozen_string_literal: true

class Facilities::DiscardReasonComponent < ViewComponent::Base
  attr_reader :discard_reason

  VALID_REASONS = {
    nil => "None",
    none: "None",
    closed: "Closed",
    duplicated: "Duplicated",
    sync_removed: "Removed by Sync"
  }.freeze

  def initialize(discard_reason)
    super()

    @discard_reason = discard_reason&.to_sym
  end

  def self.select_options
    VALID_REASONS.invert.to_a
  end

  def call
    text = VALID_REASONS[discard_reason.presence] || "Unsupported value '#{discard_reason}'"
    tag.span(text)
  end
end
