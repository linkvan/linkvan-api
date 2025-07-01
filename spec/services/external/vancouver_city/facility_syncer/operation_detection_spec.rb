# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilitySyncer, 'operation detection', type: :service do
  let(:api_key) { 'drinking-fountains' }
  let(:service) { create(:water_fountain_service) }

  before { service } # Ensure service exists

  describe 'operation detection' do
    context 'when no existing facility found' do
      let(:new_facility_record) do
        {
          'mapid' => 'NEW123',
          'name' => 'Brand New Fountain',
          'location' => 'New Park',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'sets operation to :create' do
        syncer = described_class.new(record: new_facility_record, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to eq(:create)
      end

      it 'creates a new facility' do
        expect do
          syncer = described_class.new(record: new_facility_record, api_key: api_key)
          syncer.call
        end.to change(Facility, :count).by(1)
      end
    end

    context 'when existing facility has external_id' do
      let!(:existing_external_facility) do
        create(:facility, 
               :with_verified,
               external_id: 'EXT123', 
               name: 'External Fountain')
      end

      let(:update_record) do
        {
          'mapid' => 'EXT123',
          'name' => 'Updated External Fountain',
          'location' => 'Updated Park',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'sets operation to :external_update' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to eq(:external_update)
      end

      it 'returns the existing facility' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result.data.facility.id).to eq(existing_external_facility.id)
      end

      it 'does not create a new facility' do
        expect do
          syncer = described_class.new(record: update_record, api_key: api_key)
          syncer.call
        end.not_to change(Facility, :count)
      end
    end

    context 'when existing facility found by name only' do
      let!(:existing_internal_facility) do
        create(:facility,
               external_id: nil,
               name: 'Internal Fountain',
               verified: false)
      end

      let(:name_match_record) do
        {
          'mapid' => 'NEW456',
          'name' => 'Internal Fountain', # Matches existing facility name
          'location' => 'Same Park',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'sets operation to :internal_update' do
        syncer = described_class.new(record: name_match_record, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to eq(:internal_update)
      end

      it 'returns the existing facility' do
        syncer = described_class.new(record: name_match_record, api_key: api_key)
        result = syncer.call

        expect(result.data.facility.id).to eq(existing_internal_facility.id)
      end

      it 'does not create a new facility' do
        expect do
          syncer = described_class.new(record: name_match_record, api_key: api_key)
          syncer.call
        end.not_to change(Facility, :count)
      end
    end

    context 'with complex matching scenarios' do
      let!(:facility_with_external_id) do
        create(:facility,
               :with_verified,
               external_id: 'EXT789',
               name: 'Shared Name Fountain')
      end

      let!(:facility_with_same_name) do
        create(:facility,
               external_id: nil,
               name: 'Shared Name Fountain',
               verified: false)
      end

      it 'prioritizes external_id match over name match' do
        record = {
          'mapid' => 'EXT789',
          'name' => 'Shared Name Fountain',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }

        syncer = described_class.new(record: record, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to eq(:external_update)
        expect(result.data.facility.id).to eq(facility_with_external_id.id)
      end

      it 'handles facilities with same name but different external_id' do
        record = {
          'mapid' => 'DIFFERENT123',
          'name' => 'Shared Name Fountain',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }

        syncer = described_class.new(record: record, api_key: api_key)
        result = syncer.call

        # Should match by name since external_id is different
        expect(result.data.operation).to eq(:internal_update)
        expect(result.data.facility.id).to eq(facility_with_same_name.id)
      end
    end
  end
end
