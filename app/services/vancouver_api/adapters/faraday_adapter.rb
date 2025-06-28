# frozen_string_literal: true

require 'faraday'

module VancouverApi
  module Adapters
    # Faraday HTTP adapter for the Vancouver API client
    # Uses the builder pattern for flexible configuration
    class FaradayAdapter
      attr_reader :connection

      def initialize(connection)
        @connection = connection
      end

      def self.create(vancouver_api_config)
        builder(vancouver_api_config.base_url)
          .timeout(vancouver_api_config.timeout)
          .open_timeout(vancouver_api_config.open_timeout)
          .build
      end

      # Builder class for creating configured Faraday connections
      class Builder
        DEFAULT_TIMEOUT = 30
        DEFAULT_OPEN_TIMEOUT = 10
        DEFAULT_USER_AGENT = 'Linkvan API Client'

        def initialize(base_url)
          @base_url = base_url
          @timeout = DEFAULT_TIMEOUT
          @open_timeout = DEFAULT_OPEN_TIMEOUT
          @user_agent = DEFAULT_USER_AGENT
          @headers = {}
          @adapter = Faraday.default_adapter
        end
        # Set request timeout
        # @param timeout [Integer] Request timeout in seconds
        # @return [Builder] self for method chaining
        def timeout(timeout)
          @timeout = timeout
          self
        end

        # Set connection timeout
        # @param open_timeout [Integer] Connection timeout in seconds
        # @return [Builder] self for method chaining
        def open_timeout(open_timeout)
          @open_timeout = open_timeout
          self
        end

        # Set user agent string
        # @param user_agent [String] User agent for requests
        # @return [Builder] self for method chaining
        def user_agent(user_agent)
          @user_agent = user_agent
          self
        end

        # Add custom header
        # @param name [String] Header name
        # @param value [String] Header value
        # @return [Builder] self for method chaining
        def header(name, value)
          @headers[name] = value
          self
        end

        # Set Faraday adapter
        # @param adapter [Symbol, Object] Faraday adapter
        # @return [Builder] self for method chaining
        def adapter(adapter)
          @adapter = adapter
          self
        end

        # Build the configured Faraday connection
        # @return [FaradayAdapter] Configured adapter instance
        def build
          connection = Faraday.new(url: @base_url) do |config|
            config.adapter @adapter
            
            # Set timeouts
            config.options.timeout = @timeout
            config.options.open_timeout = @open_timeout
            
            # Set default headers
            config.headers['User-Agent'] = @user_agent
            config.headers['Accept'] = 'application/json'
            
            # Add custom headers
            @headers.each do |name, value|
              config.headers[name] = value
            end
          end

          FaradayAdapter.new(connection)
        end
      end

      # Create a new builder for the given base URL
      # @param base_url [String] The base URL for the API
      # @return [Builder] A new builder instance
      def self.builder(base_url)
        Builder.new(base_url)
      end

      # Delegate HTTP methods to the Faraday connection
      def get(path, params = {})
        @connection.get(path, params)
      end

      def post(path, body = nil, params = {})
        @connection.post(path, body, params)
      end

      def put(path, body = nil, params = {})
        @connection.put(path, body, params)
      end

      def delete(path, params = {})
        @connection.delete(path, params)
      end

      def patch(path, body = nil, params = {})
        @connection.patch(path, body, params)
      end

      # Access connection options for testing
      def options
        @connection.options
      end

      # Access connection headers for testing
      def headers
        @connection.headers
      end

      # Access connection URL prefix for testing
      def url_prefix
        @connection.url_prefix
      end
    end
  end
end
