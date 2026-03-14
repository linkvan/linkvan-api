# frozen_string_literal: true

module External
  module VancouverCity
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
end
