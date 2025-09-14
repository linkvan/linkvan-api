# frozen_string_literal: true

require 'rails_helper'

# Trigger autoloading
External::VancouverCity::VancouverApiClient if defined?(External::VancouverCity)

# Test the custom error class
RSpec.describe External::VancouverCity::VancouverApiError, type: :service do
  describe '#initialize' do
    it 'sets message, status_code, and response_body' do
      error = described_class.new('Test error', 404, '{"error": "Not found"}')
      
      expect(error.message).to eq('Test error')
      expect(error.status_code).to eq(404)
      expect(error.response_body).to eq('{"error": "Not found"}')
    end

    it 'works with minimal parameters' do
      error = described_class.new('Simple error')
      
      expect(error.message).to eq('Simple error')
      expect(error.status_code).to be_nil
      expect(error.response_body).to be_nil
    end

    it 'inherits from StandardError' do
      expect(described_class.new('test')).to be_a(StandardError)
    end
  end

  describe 'error attributes' do
    let(:error) { described_class.new('Test message', 500, 'Error body') }

    it 'provides read access to status_code' do
      expect(error.status_code).to eq(500)
    end

    it 'provides read access to response_body' do
      expect(error.response_body).to eq('Error body')
    end
  end
end
