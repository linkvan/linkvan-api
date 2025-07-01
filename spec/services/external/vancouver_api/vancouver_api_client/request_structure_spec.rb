# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_helpers'

RSpec.describe External::VancouverCity::VancouverApiClient, 'request structure and parameters', type: :service do
  include_context 'vancouver api client shared setup'

  let(:mock_adapter) { instance_double(External::VancouverCity::Adapters::FaradayAdapter) }
  let(:test_client) { create_test_client_with_mock_adapter(mock_adapter) }
  let(:mock_response) { create_successful_mock_response('{"results": []}') }

  before do
    allow(mock_adapter).to receive(:get).and_return(mock_response)
  end

  describe 'parameter edge cases' do
    it 'handles special characters in parameters' do
      params = { where: 'name = "O\'Reilly Park"', select: 'field with spaces' }
      
      test_client.get_dataset_records('test-dataset', **params)
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/test-dataset/records", params)
    end

    it 'handles large limit values' do
      test_client.get_dataset_records('test-dataset', limit: 100)
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/test-dataset/records", { limit: 100 })
    end

    it 'handles zero offset' do
      test_client.get_dataset_records('test-dataset', offset: 0)
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/test-dataset/records", { offset: 0 })
    end
  end

  describe 'request structure and headers' do
    it 'uses GET method for all requests' do
      test_client.get_dataset_records('test-dataset')
      test_client.get_dataset('test-dataset')
      test_client.get_datasets
      test_client.get_dataset_record('test-dataset', 'record-1')
      
      expect(mock_adapter).to have_received(:get).exactly(4).times
    end

    it 'constructs proper paths for different endpoints' do
      test_client.get_dataset_records('drinking-fountains')
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/drinking-fountains/records", {})

      test_client.get_dataset('drinking-fountains')
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/drinking-fountains", {})

      test_client.get_datasets
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets", {})

      test_client.get_dataset_record('drinking-fountains', 'DFPB0001')
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/drinking-fountains/records/DFPB0001", {})
    end
  end

  describe 'JSON response parsing' do
    context 'when response is successful but not JSON' do
      let(:non_json_response) do
        instance_double(Faraday::Response,
          success?: true,
          status: 200,
          body: 'plain text response',
          headers: { 'content-type' => 'text/plain' }
        )
      end

      before do
        allow(mock_adapter).to receive(:get).and_return(non_json_response)
      end

      it 'returns response without parsing body' do
        response = test_client.get_dataset_records('test-dataset')
        
        expect(response.success?).to be true
        expect(response.body).to eq('plain text response')
      end
    end

    context 'when response has mixed content-type' do
      let(:json_response_with_charset) { create_successful_mock_response('{"data": "test"}') }

      before do
        allow(json_response_with_charset).to receive(:headers)
          .and_return({ 'content-type' => 'application/json; charset=utf-8' })
        allow(mock_adapter).to receive(:get).and_return(json_response_with_charset)
      end

      it 'still parses JSON correctly' do
        response = test_client.get_dataset_records('test-dataset')
        
        expect(response.success?).to be true
      end
    end
  end

  describe 'query parameter building' do
    it 'maps options to parameter names correctly' do
      options = {
        select: 'name,location',
        where: 'maintainer = "Parks"',
        group_by: 'maintainer',
        order_by: 'name asc',
        limit: 50,
        offset: 10,
        refine: 'category:park',
        exclude: 'status:inactive',
        lang: 'en',
        timezone: 'UTC',
        include_links: true,
        include_app_metas: false
      }

      test_client.get_dataset_records('test-dataset', **options)
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/test-dataset/records", options)
    end

    it 'filters out nil values' do
      options = {
        select: 'name',
        where: nil,
        limit: 10,
        offset: nil
      }

      test_client.get_dataset_records('test-dataset', **options)
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/test-dataset/records", { select: 'name', limit: 10 })
    end

    it 'handles empty options' do
      test_client.get_dataset_records('test-dataset')
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/test-dataset/records", {})
    end
  end
end
