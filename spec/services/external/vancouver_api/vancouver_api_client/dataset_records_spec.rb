# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_helpers'

RSpec.describe External::VancouverCity::VancouverApiClient, '#get_dataset_records', type: :service do
  include_context 'vancouver api client shared setup'

  let(:dataset_id) { 'drinking-fountains' }
  let(:mock_adapter) { instance_double(External::VancouverCity::Adapters::FaradayAdapter) }
  let(:test_client) { create_test_client_with_mock_adapter(mock_adapter) }
  let(:response_body) do
    {
      'total_count' => 278,
      'results' => [
        {
          'mapid' => 'DFPB0001',
          'name' => 'Fountain location: Aberdeen Park',
          'location' => 'plaza',
          'maintainer' => 'Parks'
        }
      ]
    }
  end

  context 'successful request' do
    let(:mock_response) { create_successful_mock_response(response_body.to_json) }

    before do
      allow(mock_adapter).to receive(:get)
        .with("catalog/datasets/#{dataset_id}/records", { limit: 20 })
        .and_return(mock_response)
    end

    it 'returns successful response with parsed body' do
      response = test_client.get_dataset_records(dataset_id, limit: 20)
      
      expect(response.success?).to be true
      expect(response.status).to eq(200)
    end

    it 'calls the adapter with correct parameters' do
      test_client.get_dataset_records(dataset_id, limit: 20)
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/#{dataset_id}/records", { limit: 20 })
    end
  end

  context 'with query parameters' do
    let(:params) do
      {
        select: 'name,location',
        where: 'maintainer = "Parks"',
        order_by: 'name asc',
        limit: 50,
        offset: 10
      }
    end
    let(:mock_response) { create_successful_mock_response(response_body.to_json) }

    before do
      allow(mock_adapter).to receive(:get).and_return(mock_response)
    end

    it 'passes all query parameters correctly' do
      test_client.get_dataset_records(dataset_id, **params)
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/#{dataset_id}/records", params)
    end
  end

  context 'with nil parameters' do
    let(:mock_response) { create_successful_mock_response(response_body.to_json) }

    before do
      allow(mock_adapter).to receive(:get).and_return(mock_response)
    end

    it 'filters out nil values from parameters' do
      test_client.get_dataset_records(dataset_id, limit: 10, where: nil, select: nil)
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/#{dataset_id}/records", { limit: 10 })
    end
  end
end
