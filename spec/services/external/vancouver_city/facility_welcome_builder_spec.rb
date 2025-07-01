# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilityWelcomeBuilder, type: :service do
  let(:facility) { build(:facility) }
  let(:fields) { { 'name' => 'Test Facility' } }

  describe '#initialize' do
    it 'initializes with valid parameters' do
      builder = described_class.new(facility: facility, fields: fields)
      
      expect(builder.facility).to eq(facility)
      expect(builder.fields).to eq(fields)
    end
  end

  describe '#validate' do
    context 'with valid parameters' do
      let(:builder) { described_class.new(facility: facility, fields: fields) }

      it 'returns empty errors array' do
        expect(builder.validate).to be_empty
      end

      it 'is valid' do
        expect(builder).to be_valid
      end
    end

    context 'with nil facility' do
      let(:builder) { described_class.new(facility: nil, fields: fields) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Facility is required')
      end

      it 'is invalid' do
        expect(builder).to be_invalid
      end
    end

    context 'with non-facility object' do
      let(:builder) { described_class.new(facility: 'invalid', fields: fields) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Facility must be a Facility object')
      end
    end

    context 'with nil fields' do
      let(:builder) { described_class.new(facility: facility, fields: nil) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Fields are required')
      end
    end

    context 'with non-hash fields' do
      let(:builder) { described_class.new(facility: facility, fields: 'invalid') }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Fields must be a Hash')
      end
    end
  end

  describe '#call' do
    context 'with valid parameters' do
      let(:builder) { described_class.new(facility: facility, fields: fields) }

      it 'returns successful result' do
        result = builder.call
        
        expect(result).to be_success
        expect(result.errors).to be_empty
        expect(result.data[:welcomes_count]).to be > 0
      end

      it 'creates facility welcomes for all customer types' do
        builder.call

        expect(facility.facility_welcomes).not_to be_empty
        # Test that welcomes are created (exact count depends on FacilityWelcome.all_customers)
      end

      it 'creates valid welcome objects' do
        builder.call

        facility.facility_welcomes.each do |welcome|
          expect(welcome).to be_valid, "Expected welcome to be valid: #{welcome.errors.full_messages}"
        end
      end
    end

    context 'with invalid parameters' do
      let(:builder) { described_class.new(facility: nil, fields: nil) }

      it 'returns error result without building welcomes' do
        result = builder.call

        expect(result).to be_failed
        expect(result.data).to be_nil
        expect(result.errors).to include('Facility is required')
        expect(result.errors).to include('Fields are required')
      end
    end
  end

  describe '.call class method' do
    it 'works as a class method' do
      result = described_class.call(facility: facility, fields: fields)
      
      expect(result).to be_success
      expect(result.data[:welcomes_count]).to be > 0
    end
  end
end
