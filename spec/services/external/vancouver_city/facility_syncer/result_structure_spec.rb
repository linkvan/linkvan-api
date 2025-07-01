# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilitySyncer, 'result structure', type: :service do
  let(:api_key) { 'drinking-fountains' }
  let(:service) { create(:service, key: api_key) }

  before { service }

  describe 'ResultData structure' do
    let(:valid_record) do
      {
        'mapid' => 'RESULT123',
        'name' => 'Test Fountain',
        'location' => 'Test Park',
        'geo_local_area' => 'Downtown',
        'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
      }
    end

    it 'returns ResultData with operation and facility' do
      syncer = described_class.new(record: valid_record, api_key: api_key)
      result = syncer.call

      expect(result.data).to be_a(External::VancouverCity::FacilitySyncer::ResultData)
      expect(result.data).to respond_to(:operation)
      expect(result.data).to respond_to(:facility)
    end

    it 'delegates present? and blank? to facility' do
      syncer = described_class.new(record: valid_record, api_key: api_key)
      result = syncer.call

      # When facility is present
      expect(result.data.present?).to be true
      expect(result.data.blank?).to be false
    end

    context 'when FacilityBuilder fails' do
      let(:invalid_record) do
        {
          'mapid' => 'INVALID123',
          'name' => '', # Empty name causes FacilityBuilder to fail
          'location' => 'Test Location',
          'geo_local_area' => 'Downtown',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'ResultData reflects early failure state' do
        syncer = described_class.new(record: invalid_record, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to be_nil  # No operation determined when FacilityBuilder fails
        expect(result.data.facility).to be_nil
        expect(result.data.blank?).to be true
        expect(result.data.present?).to be false
      end
    end

    context 'when FacilityBuilder fails' do
      let(:malformed_record) do
        {
          'mapid' => nil,
          'location' => 'Test Location'
        }
      end

      it 'ResultData shows nil operation and facility' do
        syncer = described_class.new(record: malformed_record, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to be_nil
        expect(result.data.facility).to be_nil
        expect(result.data.blank?).to be true
        expect(result.data.present?).to be false
      end
    end
  end

  describe 'Result object compliance with ApplicationService::Result' do
    let(:valid_record) do
      {
        'mapid' => 'COMPLIANCE123',
        'name' => 'Test Fountain',
        'location' => 'Test Park',
        'geo_local_area' => 'Downtown',
        'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
      }
    end

    it 'returns ApplicationService::Result object' do
      syncer = described_class.new(record: valid_record, api_key: api_key)
      result = syncer.call

      expect(result).to be_a(ApplicationService::Result)
      expect(result).to respond_to(:data)
      expect(result).to respond_to(:errors)
      expect(result).to respond_to(:success?)
      expect(result).to respond_to(:failed?)
    end

    context 'when operation succeeds' do
      it 'has success? true and failed? false' do
        syncer = described_class.new(record: valid_record, api_key: api_key)
        result = syncer.call

        expect(result.success?).to be true
        expect(result.failed?).to be false
        expect(result.errors).to be_blank
      end
    end

    context 'when operation fails' do
      let(:invalid_record) do
        {
          'mapid' => 'FAIL123',
          'name' => '',
          'location' => 'Test Location',
          'geo_local_area' => 'Downtown',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'has success? false and failed? true' do
        syncer = described_class.new(record: invalid_record, api_key: api_key)
        result = syncer.call

        expect(result.success?).to be false
        expect(result.failed?).to be true
        expect(result.errors).to be_present
      end
    end
  end

  describe 'operation type consistency' do
    context 'for create operations' do
      let(:create_record) do
        {
          'mapid' => 'CREATE_OP123',
          'name' => 'New Fountain',
          'location' => 'New Park',
          'geo_local_area' => 'Downtown',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'consistently reports :create operation' do
        syncer = described_class.new(record: create_record, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to eq(:create)
      end
    end

    context 'for external_update operations' do
      let!(:existing_external_facility) do
        create(:facility,
               external_id: 'EXT_OP123',
               name: 'Old Name')
      end

      let(:update_record) do
        {
          'mapid' => 'EXT_OP123',
          'name' => 'Updated Name',
          'location' => 'Updated Location',
          'geo_local_area' => 'Downtown',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'consistently reports :external_update operation' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to eq(:external_update)
      end
    end

    context 'for internal_update operations' do
      let!(:existing_internal_facility) do
        create(:facility,
               external_id: nil,
               name: 'Internal Facility')
      end

      let(:update_record) do
        {
          'mapid' => 'INT_OP123',
          'name' => 'Internal Facility', # Same name triggers internal_update
          'location' => 'Updated Location',
          'geo_local_area' => 'Downtown',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'consistently reports :internal_update operation' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to eq(:internal_update)
      end
    end
  end

  describe 'facility reference consistency' do
    let(:valid_record) do
      {
        'mapid' => 'REF123',
        'name' => 'Reference Test Fountain',
        'location' => 'Test Park',
        'geo_local_area' => 'Downtown',
        'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
      }
    end

    it 'result facility matches database record' do
      syncer = described_class.new(record: valid_record, api_key: api_key)
      result = syncer.call

      db_facility = Facility.find(result.data.facility.id)
      expect(result.data.facility).to eq(db_facility)
      expect(result.data.facility.external_id).to eq('REF123')
      expect(result.data.facility.name).to eq('Reference Test Fountain')
    end

    context 'with update operations' do
      let!(:existing_facility) do
        create(:facility,
               external_id: 'UPDATE_REF123',
               name: 'Original Name')
      end

      let(:update_record) do
        {
          'mapid' => 'UPDATE_REF123',
          'name' => 'Updated Reference Name',
          'location' => 'Updated Location',
          'geo_local_area' => 'Downtown',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'result facility is the same instance as existing facility' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result.data.facility.id).to eq(existing_facility.id)
        expect(result.data.facility).to be_a(Facility)
      end
    end
  end
end
