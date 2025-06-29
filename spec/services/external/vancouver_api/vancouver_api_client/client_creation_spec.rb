# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_helpers'

RSpec.describe External::VancouverCity::VancouverApiClient, 'client creation and initialization', type: :service do
  include_context 'vancouver api client shared setup'

  describe '.default' do
    it 'creates a client with the default adapter' do
      client = described_class.default
      expect(client.adapter).to eq(External::VancouverCity::DEFAULT_ADAPTER)
    end
  end

  describe '.with_config' do
    it 'creates a client with custom configuration' do
      config = External::VancouverCity::VancouverApiConfig.new(timeout: 60, open_timeout: 20)
      client = described_class.with_config(config)
      
      adapter = client.adapter
      expect(adapter.options.timeout).to eq(60)
      expect(adapter.options.open_timeout).to eq(20)
    end
  end

  describe '.with_timeouts' do
    it 'creates a client with custom timeout values' do
      client = described_class.with_timeouts(timeout: 120, open_timeout: 30)
      
      adapter = client.adapter
      expect(adapter.options.timeout).to eq(120)
      expect(adapter.options.open_timeout).to eq(30)
    end
  end

  describe '#initialize' do
    context 'with default adapter' do
      it 'uses the provided adapter' do
        adapter = client.adapter
        expect(adapter).to eq(default_adapter)
      end
    end

    context 'with custom adapter' do
      let(:mock_adapter) { instance_double(External::VancouverCity::Adapters::FaradayAdapter) }
      let(:client) { described_class.new(adapter: mock_adapter) }

      it 'uses the provided adapter' do
        expect(client.adapter).to eq(mock_adapter)
      end
    end
  end
end
