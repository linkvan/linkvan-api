# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VancouverApi::Adapters::FaradayAdapter, type: :service do
  let(:base_url) { 'https://api.example.com' }

  describe '.builder' do
    it 'returns a builder instance' do
      builder = described_class.builder(base_url)
      expect(builder).to be_a(described_class::Builder)
    end
  end

  describe 'Builder' do
    let(:builder) { described_class.builder(base_url) }

    describe '#build' do
      it 'creates an adapter with default configuration' do
        adapter = builder.build
        
        expect(adapter).to be_a(described_class)
        expect(adapter.options.timeout).to eq(30)
        expect(adapter.options.open_timeout).to eq(10)
        expect(adapter.headers['User-Agent']).to eq('Linkvan API Client')
        expect(adapter.headers['Accept']).to eq('application/json')
        expect(adapter.url_prefix.to_s).to eq("#{base_url}/")
      end

      it 'creates an adapter with custom configuration' do
        adapter = builder
          .timeout(60)
          .open_timeout(20)
          .user_agent('Custom Agent')
          .header('Custom-Header', 'custom-value')
          .build
        
        expect(adapter.options.timeout).to eq(60)
        expect(adapter.options.open_timeout).to eq(20)
        expect(adapter.headers['User-Agent']).to eq('Custom Agent')
        expect(adapter.headers['Custom-Header']).to eq('custom-value')
      end
    end

    describe 'fluent interface' do
      it 'allows method chaining' do
        result = builder
          .timeout(45)
          .open_timeout(15)
          .user_agent('Test Agent')
          .header('X-Test', 'value')
        
        expect(result).to be(builder)
      end
    end
  end

  describe 'HTTP method delegation' do
    let(:mock_connection) { instance_double(Faraday::Connection) }
    let(:adapter) { described_class.new(mock_connection) }

    it 'delegates get to connection' do
      allow(mock_connection).to receive(:get)
      adapter.get('/path', { param: 'value' })
      expect(mock_connection).to have_received(:get).with('/path', { param: 'value' })
    end

    it 'delegates post to connection' do
      allow(mock_connection).to receive(:post)
      adapter.post('/path', { data: 'value' })
      expect(mock_connection).to have_received(:post).with('/path', { data: 'value' }, {})
    end

    it 'delegates other HTTP methods' do
      %w[put delete patch].each do |method|
        allow(mock_connection).to receive(method.to_sym)
        adapter.send(method, '/path')
        expect(mock_connection).to have_received(method.to_sym)
      end
    end
  end
end
