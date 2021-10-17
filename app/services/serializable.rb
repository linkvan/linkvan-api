# frozen_string_literal: true

module Serializable
  extend ActiveSupport::Concern

  protected

  # Returns a hash containing data collected from a object.
  #   expects to receive:
  #   - object - that to collect data from.
  #   - columns_hash - containing:
  #     - key is the method_name to be sent to the object,
  #     - value is the key_name to be used in the returning hash
  def hashify(object, columns_hash)
    result = {}

    config = columns_hash
    # transforms the array in a hash with repeated key/value
    config = columns_hash.map { |v| [v, v] }.to_h if columns_hash.is_a?(Array)

    config.each_pair do |method_name, key_name|
      result[key_name] = object.blank? ? "" : object.public_send(method_name)
    end

    result
  end
end
