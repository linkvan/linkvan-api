# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilitySyncer, 'FacilityBuilder integration', type: :service do
  let(:api_key) { 'drinking-fountains' }
  let(:service) { create(:service, key: api_key) }

  before { service } # Ensure service exists

  describe 'FacilityBuilder integration' do
    context 'when FacilityBuilder succeeds with valid facility' do
      let(:valid_record) do
        {
          'mapid' => '12345',
          'name' => 'Test Fountain',
          'location' => 'Test Park',
          'geo_local_area' => 'Downtown',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'proceeds with sync operations' do
        syncer = described_class.new(record: valid_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        expect(result.data.operation).to eq(:create)
        expect(result.data.facility).to be_present
      end

      it 'facility is created and persisted' do
        syncer = described_class.new(record: valid_record, api_key: api_key)
        result = syncer.call

        expect(result.data.facility).to be_persisted
        expect(result.data.facility.name).to eq('Test Fountain')
        expect(result.data.facility.external_id).to eq('12345')
      end
    end

    context 'when FacilityBuilder fails due to invalid record' do
      let(:invalid_record) do
        {
          # Missing required fields like name and coordinates
        }
      end

      it 'returns early with FacilityBuilder errors' do
        syncer = described_class.new(record: invalid_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to be_present
      end

      it 'returns ResultData with operation: nil, facility: nil' do
        syncer = described_class.new(record: invalid_record, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to be_nil
        expect(result.data.facility).to be_nil
      end

      it 'does not attempt database operations' do
        expect(Facility).not_to receive(:where)
        
        syncer = described_class.new(record: invalid_record, api_key: api_key)
        syncer.call
      end
    end

    context 'when FacilityBuilder fails due to invalid facility data' do
      # This scenario occurs when FacilityBuilder receives data that would create
      # an invalid facility, so it fails validation and returns errors
      let(:record_with_invalid_facility_data) do
        {
          'mapid' => '12345',
          'name' => '', # Empty name will make facility invalid
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'returns early with validation errors' do
        syncer = described_class.new(record: record_with_invalid_facility_data, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.data.operation).to be_nil  # No operation determined
        expect(result.data.facility).to be_nil   # No facility created
      end

      it 'includes FacilityBuilder validation errors' do
        syncer = described_class.new(record: record_with_invalid_facility_data, api_key: api_key)
        result = syncer.call

        expect(result.errors).to include(a_string_matching(/can't be blank/i))
      end

      it 'does not attempt to save anything' do
        expect do
          syncer = described_class.new(record: record_with_invalid_facility_data, api_key: api_key)
          syncer.call
        end.not_to change(Facility, :count)
      end
    end
  end
end
