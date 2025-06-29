# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_context 'vancouver api client shared setup' do
  let(:default_adapter) { External::VancouverCity::DEFAULT_ADAPTER }
  let(:client) { described_class.new(adapter: default_adapter) }
  let(:base_url) { 'https://opendata.vancouver.ca/api/explore/v2.1' }

  # Helper method to create a test client with a mock adapter
  def create_test_client_with_mock_adapter(mock_adapter)
    described_class.new(adapter: mock_adapter)
  end

  # Helper to create a successful mock response
  def create_successful_mock_response(body = '{"results": []}')
    instance_double(Faraday::Response,
      success?: true,
      status: 200,
      body: body,
      headers: { 'content-type' => 'application/json' },
      env: double(body: nil)
    ).tap do |response|
      allow(response.env).to receive(:body=)
    end
  end

  # Helper to create an error mock response
  def create_error_mock_response(status:, body:, content_type: 'text/html')
    instance_double(Faraday::Response,
      success?: false,
      status: status,
      body: body,
      headers: { 'content-type' => content_type }
    )
  end
end
