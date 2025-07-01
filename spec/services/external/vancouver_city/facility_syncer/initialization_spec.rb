# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilitySyncer, '#initialize', type: :service do
  describe '#initialize' do
    let(:record) { { 'name' => 'Test Facility' } }
    let(:api_key) { 'test-api-key' }

    it 'sets record and api_key' do
      syncer = described_class.new(record: record, api_key: api_key)
      
      expect(syncer.record).to eq(record)
      expect(syncer.api_key).to eq(api_key)
    end

    it 'inherits from ApplicationService' do
      syncer = described_class.new(record: record, api_key: api_key)
      
      expect(syncer).to be_a(ApplicationService)
    end

    it 'responds to call method' do
      syncer = described_class.new(record: record, api_key: api_key)
      
      expect(syncer).to respond_to(:call)
    end
  end
end
