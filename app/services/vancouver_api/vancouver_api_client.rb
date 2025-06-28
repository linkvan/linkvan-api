# frozen_string_literal: true

require 'faraday'
require 'json'
require_relative 'adapters/faraday_adapter'

module VancouverApi
  class VancouverApiConfig
    BASE_URL = 'https://opendata.vancouver.ca/api/explore/v2.1'
    DEFAULT_TIMEOUT = 30 # seconds
    DEFAULT_OPEN_TIMEOUT = 10 # seconds

    attr_reader :base_url, :timeout, :open_timeout

    def initialize(base_url: nil, timeout: nil, open_timeout: nil)
      @base_url = base_url || BASE_URL
      @timeout = timeout || DEFAULT_TIMEOUT
      @open_timeout = open_timeout || DEFAULT_OPEN_TIMEOUT
    end
  end

  DEFAULT_ADAPTER = Adapters::FaradayAdapter.builder(VancouverApiConfig::BASE_URL)
        .timeout(VancouverApiConfig::DEFAULT_TIMEOUT)
        .open_timeout(VancouverApiConfig::DEFAULT_OPEN_TIMEOUT)
        .build

  # HTTP client for the Vancouver Open Data API (Opendatasoft Explore API v2.1)
  # 
  # This client provides access to Vancouver's open data portal at:
  # https://opendata.vancouver.ca/api/explore/v2.1/
  #
  # Example usage:
  #   # Using the default adapter
  #   client = VancouverApi::VancouverApiClient.new(adapter: VancouverApi::DEFAULT_ADAPTER)
  #   
  #   # Using a custom configuration
  #   config = VancouverApi::VancouverApiConfig.new(timeout: 60)
  #   adapter = VancouverApi::Adapters::FaradayAdapter.create(config)
  #   client = VancouverApi::VancouverApiClient.new(adapter: adapter)
  #   
  #   response = client.get_dataset_records('drinking-fountains', limit: 20)
  #   records = response.body
  class VancouverApiClient
    attr_reader :adapter

    # Create a client with the default adapter
    # @return [VancouverApiClient] Client instance with default configuration
    def self.default
      new(adapter: DEFAULT_ADAPTER)
    end

    # Create a client with custom configuration
    # @param config [VancouverApiConfig] Custom configuration
    # @return [VancouverApiClient] Client instance with custom configuration
    def self.with_config(config)
      adapter = Adapters::FaradayAdapter.create(config)
      new(adapter: adapter)
    end

    # Create a client with custom timeout values
    # @param timeout [Integer] Request timeout in seconds
    # @param open_timeout [Integer] Connection timeout in seconds
    # @return [VancouverApiClient] Client instance with custom timeouts
    def self.with_timeouts(timeout: 30, open_timeout: 10)
      config = VancouverApiConfig.new(timeout: timeout, open_timeout: open_timeout)
      with_config(config)
    end

    # Initialize the client with a mandatory adapter
    # @param adapter [FaradayAdapter] Pre-configured HTTP adapter (required)
    def initialize(adapter:)
      @adapter = adapter
    end

    # Get records from a dataset
    #
    # @param dataset_id [String] The identifier of the dataset (e.g., 'drinking-fountains')
    # @param options [Hash] Query parameters for the API request
    # @option options [String] :select Fields to select (default: '*' for all fields)
    # @option options [String] :where Filter expression using ODSQL
    # @option options [String] :order_by Sort expression (e.g., 'name asc')
    # @option options [Integer] :limit Number of records to return (max 100, default 10)
    # @option options [Integer] :offset Starting index for pagination (default 0)
    # @option options [String] :group_by Group by expression for aggregations
    # @option options [String] :refine Facet refinement (e.g., 'field:value')
    # @option options [String] :exclude Facet exclusion (e.g., 'field:value')
    # @option options [String] :lang Language for formatting (default 'en')
    # @option options [String] :timezone Timezone for date formatting
    # @option options [Boolean] :include_links Whether to include navigation links
    # @option options [Boolean] :include_app_metas Whether to include application metadata
    # @return [Faraday::Response] The HTTP response containing the dataset records
    # @raise [VancouverApiError] If the API request fails
    #
    # @example Get first 20 drinking fountains
    #   client.get_dataset_records('drinking-fountains', limit: 20)
    #
    # @example Get fountains with specific filters
    #   client.get_dataset_records('drinking-fountains', 
    #     where: 'location_type = "Park"',
    #     order_by: 'name asc',
    #     limit: 50
    #   )
    def get_dataset_records(dataset_id, **options)
      # Build query parameters, filtering out nil values
      params = build_query_params(options)
      
      # Make the API request
      path = "catalog/datasets/#{dataset_id}/records"
      
      handle_response do
        @adapter.get(path, params)
      end
    end

    # Get information about a specific dataset
    #
    # @param dataset_id [String] The identifier of the dataset
    # @param options [Hash] Query parameters
    # @option options [String] :lang Language for formatting (default 'en')
    # @option options [Boolean] :include_links Whether to include navigation links
    # @option options [Boolean] :include_app_metas Whether to include application metadata
    # @return [Faraday::Response] The HTTP response containing dataset information
    # @raise [VancouverApiError] If the API request fails
    def get_dataset(dataset_id, **options)
      params = build_query_params(options.slice(:lang, :include_links, :include_app_metas))
      path = "catalog/datasets/#{dataset_id}"
      
      handle_response do
        @adapter.get(path, params)
      end
    end

    # List all available datasets
    #
    # @param options [Hash] Query parameters for filtering and pagination
    # @option options [String] :select Fields to select
    # @option options [String] :where Filter expression
    # @option options [String] :order_by Sort expression
    # @option options [Integer] :limit Number of datasets to return
    # @option options [Integer] :offset Starting index for pagination
    # @option options [String] :refine Facet refinement
    # @option options [String] :exclude Facet exclusion
    # @option options [String] :lang Language for formatting
    # @return [Faraday::Response] The HTTP response containing available datasets
    # @raise [VancouverApiError] If the API request fails
    def get_datasets(**options)
      params = build_query_params(options)
      path = "catalog/datasets"
      
      handle_response do
        @adapter.get(path, params)
      end
    end

    # Get a specific record from a dataset
    #
    # @param dataset_id [String] The identifier of the dataset
    # @param record_id [String] The identifier of the specific record
    # @param options [Hash] Query parameters
    # @option options [String] :lang Language for formatting
    # @option options [String] :timezone Timezone for date formatting
    # @return [Faraday::Response] The HTTP response containing the specific record
    # @raise [VancouverApiError] If the API request fails
    def get_dataset_record(dataset_id, record_id, **options)
      params = build_query_params(options.slice(:lang, :timezone))
      path = "catalog/datasets/#{dataset_id}/records/#{record_id}"
      
      handle_response do
        @adapter.get(path, params)
      end
    end

    private

    # Build query parameters hash, removing nil values
    # @param options [Hash] The options hash to filter
    # @return [Hash] Filtered parameters hash
    def build_query_params(options)
      params = {}
      
      # Map all supported parameters
      param_mapping = {
        select: :select,
        where: :where,
        group_by: :group_by,
        order_by: :order_by,
        limit: :limit,
        offset: :offset,
        refine: :refine,
        exclude: :exclude,
        lang: :lang,
        timezone: :timezone,
        include_links: :include_links,
        include_app_metas: :include_app_metas
      }
      
      param_mapping.each do |key, param_name|
        value = options[key]
        params[param_name] = value unless value.nil?
      end
      
      params
    end

    # Handle API response and error checking
    # @yield Block that makes the HTTP request
    # @return [Faraday::Response] The successful response with parsed JSON body
    # @raise [VancouverApiError] If the request fails
    def handle_response
      response = yield
      
      # Check for HTTP errors
      unless response.success?
        error_message = "API request failed with status #{response.status}"
        
        # Try to parse error response if it's JSON
        if response.headers['content-type']&.include?('application/json')
          begin
            error_body = JSON.parse(response.body)
            error_message += ": #{error_body['error'] || error_body['message'] || response.body}"
          rescue JSON::ParserError
            error_message += ": #{response.body}"
          end
        else
          error_message += ": #{response.body[0..200]}#{'...' if response.body.length > 200}"
        end
        
        raise VancouverApiError.new(error_message, response.status, response.body)
      end
      
      # Parse JSON response body for successful responses
      if response.headers['content-type']&.include?('application/json')
        begin
          response.env.body = JSON.parse(response.body)
        rescue JSON::ParserError => e
          raise VancouverApiError.new("Failed to parse JSON response: #{e.message}", response.status, response.body)
        end
      end
      
      response
    rescue Faraday::TimeoutError => e
      raise VancouverApiError.new("Request timeout: #{e.message}", nil, nil)
    rescue Faraday::ConnectionFailed => e
      raise VancouverApiError.new("Connection failed: #{e.message}", nil, nil)
    rescue VancouverApiError
      # Re-raise our own errors without wrapping
      raise
    rescue StandardError => e
      raise VancouverApiError.new("Unexpected error: #{e.message}", nil, nil)
    end
  end

  # Custom error class for Vancouver API client errors
  class VancouverApiError < StandardError
    attr_reader :status_code, :response_body

    def initialize(message, status_code = nil, response_body = nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end
end
