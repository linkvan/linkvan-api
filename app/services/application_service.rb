# frozen_string_literal: true

# For details on how we are going about services patterns:
#   https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial
class ApplicationService
  def self.call(...)
    new(...).call
  end

  Result = Struct.new(:data, :errors, keyword_init: true) do
    def success?
      errors.blank?
    end

    def failed?
      errors.present?
    end
  end

  # This method is supposed to validate the data and return array with errors.
  def validate
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def valid?
    validate
    @errors.blank?
  end

  def invalid?
    !valid?
  end

  private

  def errors
    @errors ||= []
  end

  def add_errors(error_msgs)
    error_msgs.each { |msg| add_error(msg) }
  end

  def add_error(error_msg)
    errors << error_msg
  end
end
