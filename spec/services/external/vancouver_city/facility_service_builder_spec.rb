# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilityServiceBuilder, type: :service do
  let(:facility) { build(:facility) }
  let(:fields) { { 'name' => 'Test Facility' } }
  let(:api_key) { 'drinking-fountains' }

  describe '#initialize' do
    it 'initializes with valid parameters' do
      builder = described_class.new(facility: facility, fields: fields, api_key: api_key)
      
      expect(builder.facility).to eq(facility)
      expect(builder.fields).to eq(fields)
      expect(builder.api_key).to eq(api_key)
    end
  end

  describe '#validate' do
    context 'with valid parameters' do
      let(:builder) { described_class.new(facility: facility, fields: fields, api_key: api_key) }

      it 'returns empty errors array' do
        expect(builder.validate).to be_empty
      end

      it 'is valid' do
        expect(builder).to be_valid
      end
    end

    context 'with nil facility' do
      let(:builder) { described_class.new(facility: nil, fields: fields, api_key: api_key) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Facility is required')
      end
    end

    context 'with non-facility object' do
      let(:builder) { described_class.new(facility: 'invalid', fields: fields, api_key: api_key) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Facility must be a Facility object')
      end
    end

    context 'with nil fields' do
      let(:builder) { described_class.new(facility: facility, fields: nil, api_key: api_key) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Fields are required')
      end
    end

    context 'with non-hash fields' do
      let(:builder) { described_class.new(facility: facility, fields: 'invalid', api_key: api_key) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Fields must be a Hash')
      end
    end

    context 'with nil api_key' do
      let(:builder) { described_class.new(facility: facility, fields: fields, api_key: nil) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('API key is required')
      end
    end

    context 'with empty api_key' do
      let(:builder) { described_class.new(facility: facility, fields: fields, api_key: '') }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('API key is required')
      end
    end
  end

  describe '#call' do
    context 'with valid parameters and existing service' do
      let(:service) { create(:water_fountain_service) }
      let(:builder) { described_class.new(facility: facility, fields: fields, api_key: api_key) }

      before do
        service # Ensure service exists
      end

      it 'returns successful result' do
        result = builder.call
        
        expect(result).to be_success
        expect(result.errors).to be_empty
        expect(result.data[:services_count]).to eq(1)
      end

      it 'associates correct service with facility' do
        builder.call

        expect(facility.facility_services.size).to eq(1)
        expect(facility.facility_services.first.service).to eq(service)
      end
    end

    context 'when service does not exist' do
      let(:builder) { described_class.new(facility: facility, fields: fields, api_key: 'non-existent-service') }

      it 'returns successful result but does not create association' do
        result = builder.call
        
        expect(result).to be_success
        expect(result.errors).to be_empty
        expect(result.data[:services_count]).to eq(0)
      end

      it 'does not associate any service with facility' do
        builder.call

        expect(facility.facility_services).to be_empty
      end
    end

    context 'with invalid parameters' do
      let(:builder) { described_class.new(facility: nil, fields: nil, api_key: nil) }

      it 'returns error result without building services' do
        result = builder.call

        expect(result).to be_failed
        expect(result.data).to be_nil
        expect(result.errors).to include('Facility is required')
        expect(result.errors).to include('Fields are required')
        expect(result.errors).to include('API key is required')
      end
    end
  end

  describe '.call class method' do
    let(:service) { create(:water_fountain_service) }

    before do
      service # Ensure service exists
    end

    it 'works as a class method' do
      result = described_class.call(facility: facility, fields: fields, api_key: api_key)
      
      expect(result).to be_success
      expect(result.data[:services_count]).to eq(1)
    end
  end
end
