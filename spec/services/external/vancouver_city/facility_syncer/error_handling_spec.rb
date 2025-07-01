# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilitySyncer, 'error handling', type: :service do
  let(:api_key) { 'drinking-fountains' }
  let(:service) { create(:service, key: api_key) }

  before { service }

  describe 'transaction rollback scenarios' do
    context 'when ActiveRecord::RecordInvalid occurs during external_update' do
      let!(:existing_facility) do
        create(:facility,
               external_id: 'FAIL_UPDATE123',
               name: 'Test Facility',
               address: 'Test Address')
      end

      let(:update_record) do
        {
          'mapid' => 'FAIL_UPDATE123',
          'name' => 'Updated Name',
          'location' => 'Updated Location',
          'geo_local_area' => 'Updated Area',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Stub update! to raise RecordInvalid to simulate validation failure
        allow_any_instance_of(Facility).to receive(:update!).and_raise(
          ActiveRecord::RecordInvalid.new(existing_facility)
        )
      end

      it 'rolls back transaction and reports error' do
        original_name = existing_facility.name
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        existing_facility.reload
        expect(existing_facility.name).to eq(original_name) # No change due to rollback
        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Failed to save facility/))
        expect(result.data.operation).to eq(:external_update)
        expect(result.data.facility).to be_nil
      end
    end

    context 'when StandardError occurs during service synchronization' do
      let!(:existing_facility) do
        create(:facility,
               external_id: 'SERVICE_ERROR123',
               name: 'Test Facility')
      end

      let(:update_record) do
        {
          'mapid' => 'SERVICE_ERROR123',
          'name' => 'Updated Name',
          'location' => 'Updated Location',
          'geo_local_area' => 'Updated Area',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Stub facility_services.create! to raise StandardError
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy)
          .to receive(:create!).and_raise(StandardError.new('Database connection lost'))
      end

      it 'rolls back transaction and reports error' do
        original_service_count = existing_facility.facility_services.count
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        existing_facility.reload
        expect(existing_facility.facility_services.count).to eq(original_service_count)
        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Unexpected error during facility sync.*Database connection lost/))
        expect(result.data.operation).to eq(:external_update)
        expect(result.data.facility).to be_nil
      end
    end
  end

  describe 'logging behavior during errors' do
    let(:valid_record) do
      {
        'mapid' => 'LOG_TEST123',
        'name' => 'Test Fountain',
        'location' => 'Test Park',
        'geo_local_area' => 'Downtown',
        'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
      }
    end

    before do
      # Stub save! to raise an error to test logging
      allow_any_instance_of(Facility).to receive(:save!).and_raise(
        ActiveRecord::RecordInvalid.new(build(:facility))
      )
    end

    it 'logs errors appropriately' do
      syncer = described_class.new(record: valid_record, api_key: api_key)
      
      expect(Rails.logger).to receive(:info).with(
        a_string_matching(/Creating new facility with external_id 'LOG_TEST123'/)
      )

      syncer.call
    end
  end

  describe 'error message formatting' do
    context 'when FacilityBuilder fails due to validation errors' do
      let(:invalid_facility_record) do
        {
          'mapid' => 'INVALID123',
          'name' => '', # Invalid name causes FacilityBuilder to fail
          'location' => 'Test Location',
          'geo_local_area' => 'Downtown',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'includes detailed validation errors from FacilityBuilder' do
        syncer = described_class.new(record: invalid_facility_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors.first).to match(/Name can't be blank/)
        expect(result.data.operation).to be_nil  # No operation determined when FacilityBuilder fails
        expect(result.data.facility).to be_nil
      end
    end

    context 'when ActiveRecord::RecordInvalid provides detailed message' do
      let(:valid_record) do
        {
          'mapid' => 'DETAILED_ERROR123',
          'name' => 'Test Facility',
          'location' => 'Test Location',
          'geo_local_area' => 'Downtown',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        facility = build(:facility)
        facility.errors.add(:base, 'Custom validation error')
        
        allow_any_instance_of(Facility).to receive(:save!).and_raise(
          ActiveRecord::RecordInvalid.new(facility)
        )
      end

      it 'includes the detailed ActiveRecord error message' do
        syncer = described_class.new(record: valid_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Failed to save facility.*Custom validation error/))
      end
    end
  end
end
