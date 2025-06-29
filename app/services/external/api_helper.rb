# frozen_string_literal: true

# Configuration class for supported Vancouver City APIs and facility services
class External::ApiHelper
  # Available Vancouver City Facilities APIs
  # Each API represents a different type of facility data available from Vancouver's Open Data portal
  SUPPORTED_APIS = {
    'drinking-fountains' => 'Drinking Fountains'
  }.freeze

  class << self
    # Get all supported API options for select fields
    # @return [Array<Array>] Array of [display_name, api_key] pairs
    def api_options
      SUPPORTED_APIS.map { |key, name| [name, key] }
    end

    # Get all supported API keys
    # @return [Array<String>] Array of API keys
    def supported_api_keys
      SUPPORTED_APIS.keys
    end

    # Check if an API is supported
    # @param api_key [String] The API key to check
    # @return [Boolean] True if the API is supported
    def supported_api?(api_key)
      SUPPORTED_APIS.key?(api_key.to_s)
    end

    # Get the display name for an API
    # @param api_key [String] The API key
    # @return [String, nil] The display name or nil if not found
    def api_name(api_key)
      SUPPORTED_APIS[api_key.to_s]
    end
  end
end
