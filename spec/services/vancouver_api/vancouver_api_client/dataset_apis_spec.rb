# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_helpers'

RSpec.describe VancouverApi::VancouverApiClient, 'dataset APIs', type: :service do
  include_context 'vancouver api client shared setup'

  describe '#get_dataset' do
    let(:dataset_id) { 'drinking-fountains' }
    let(:mock_adapter) { instance_double(VancouverApi::Adapters::FaradayAdapter) }
    let(:test_client) { create_test_client_with_mock_adapter(mock_adapter) }
    let(:response_body) do
      {
        'dataset_id' => dataset_id,
        'metas' => {
          'default' => {
            'title' => 'Drinking fountains',
            'records_count' => 278
          }
        },
        'fields' => [
          { 'name' => 'mapid', 'type' => 'text' },
          { 'name' => 'name', 'type' => 'text' }
        ]
      }
    end
    let(:mock_response) { create_successful_mock_response(response_body.to_json) }

    before do
      allow(mock_adapter).to receive(:get).and_return(mock_response)
    end

    it 'calls the correct endpoint' do
      test_client.get_dataset(dataset_id)
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/#{dataset_id}", {})
    end

    it 'returns successful response' do
      response = test_client.get_dataset(dataset_id)
      
      expect(response.success?).to be true
      expect(response.status).to eq(200)
    end
  end

  describe '#get_datasets' do
    let(:mock_adapter) { instance_double(VancouverApi::Adapters::FaradayAdapter) }
    let(:test_client) { create_test_client_with_mock_adapter(mock_adapter) }
    let(:response_body) do
      {
        'total_count' => 150,
        'results' => [
          {
            'dataset_id' => 'drinking-fountains',
            'metas' => { 'default' => { 'title' => 'Drinking fountains' } }
          }
        ]
      }
    end
    let(:mock_response) { create_successful_mock_response(response_body.to_json) }

    before do
      allow(mock_adapter).to receive(:get).and_return(mock_response)
    end

    it 'calls the correct endpoint with parameters' do
      test_client.get_datasets(limit: 20)
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets", { limit: 20 })
    end

    it 'returns successful response' do
      response = test_client.get_datasets(limit: 20)
      
      expect(response.success?).to be true
      expect(response.status).to eq(200)
    end
  end

  describe '#get_dataset_record' do
    let(:dataset_id) { 'drinking-fountains' }
    let(:record_id) { 'DFPB0001' }
    let(:mock_adapter) { instance_double(VancouverApi::Adapters::FaradayAdapter) }
    let(:test_client) { create_test_client_with_mock_adapter(mock_adapter) }
    let(:response_body) do
      {
        'mapid' => record_id,
        'name' => 'Fountain location: Aberdeen Park',
        'location' => 'plaza'
      }
    end
    let(:mock_response) { create_successful_mock_response(response_body.to_json) }

    before do
      allow(mock_adapter).to receive(:get).and_return(mock_response)
    end

    it 'calls the correct endpoint' do
      test_client.get_dataset_record(dataset_id, record_id)
      
      expect(mock_adapter).to have_received(:get)
        .with("catalog/datasets/#{dataset_id}/records/#{record_id}", {})
    end

    it 'returns successful response' do
      response = test_client.get_dataset_record(dataset_id, record_id)
      
      expect(response.success?).to be true
      expect(response.status).to eq(200)
    end
  end
end
