# frozen_string_literal: true

module Discardable
  extend ActiveSupport::Concern

  included do
    scope :kept, -> { undiscarded }
    scope :undiscarded, -> { where(deleted_at: nil) }
    scope :discarded, -> { where.not(deleted_at: nil) }
    scope :with_discarded, -> { unscope(where: :deleted_at) }
  end

  module ClassMethods
    def discard_all
      kept.each(&:discard)
    end

    def discard_all!
      kept.each(&:discard!)
    end

    def undiscard_all
      discarded.each(&:undiscard)
    end

    def undiscard_all!
      discarded.each(&:undiscard!)
    end
  end

  class DiscardError < StandardError
    attr_reader :record

    def initialize(message = nil, record = nil)
      @record = record

      super(message)
    end
  end

  class RecordNotDiscarded < DiscardError; end
  class RecordNotUnDiscarded < DiscardError; end

  def discard(validate: true)
    return true if discarded?
    return update_attribute(:deleted_at, Time.current) unless validate #rubocop:disable Rails/SkipsModelValidations

    assign_attributes(deleted_at: Time.current)
    save
  end

  def discard!(validate: true)
    discard(validate: validate) || raise_record_not_discarded
  end

  def undiscard(validate: true)
    return true if undiscarded?
    return update_attribute(:deleted_at, nil) unless validate # rubocop:disable Rails/SkipsModelValidations

    assign_attributes(deleted_at: nil)
    save
  end

  def undiscard!(validate: true)
    undiscard(validate: validate) || raise_record_not_undiscarded
  end

  def discarded?
    deleted_at.present?
  end

  def undiscarded?
    deleted_at.blank?
  end

  private

  def raise_record_not_discarded
    raise RecordNotDiscarded.new("Failed to discard #{self.class}", self)
  end

  def raise_record_not_undiscarded
    raise RecordNotUnDiscarded.new("Failed to undiscard #{self.class}", self)
  end
end
