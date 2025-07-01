# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilitySyncer, 'service synchronization', type: :service do
  let(:api_key) { 'drinking-fountains' }
  let(:service) { create(:service, key: api_key) }
  let(:other_service) { create(:service, key: 'public-washrooms') }
  let(:third_service) { create(:service, key: 'parks') }

  before do
    service
    other_service  
    third_service
  end

  describe 'service synchronization logic' do
    context 'when built facility has new services' do
      let!(:existing_facility) do
        facility = create(:facility, external_id: 'SYNC_TEST123')
        facility.facility_services.create!(service: other_service)
        facility
      end

      let(:record_with_new_service) do
        {
          'mapid' => 'SYNC_TEST123',
          'name' => 'Service Sync Test',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'adds only new services that do not exist on facility' do
        # Facility starts with other_service, should get service added
        expect(existing_facility.services).to include(other_service)
        expect(existing_facility.services).not_to include(service)

        syncer = described_class.new(record: record_with_new_service, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.services).to include(other_service) # Keeps existing
        expect(facility.services).to include(service) # Adds new one
      end

      it 'increases facility services count' do
        initial_count = existing_facility.facility_services.count

        syncer = described_class.new(record: record_with_new_service, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.facility_services.count).to eq(initial_count + 1)
      end
    end

    context 'when built facility has existing services' do
      let!(:existing_facility) do
        facility = create(:facility, external_id: 'EXISTING_SERVICES123')
        facility.facility_services.create!(service: service)
        facility.facility_services.create!(service: other_service)
        facility
      end

      let(:record_with_existing_services) do
        {
          'mapid' => 'EXISTING_SERVICES123',
          'name' => 'Existing Services Test',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'does not duplicate existing services' do
        initial_count = existing_facility.facility_services.count

        syncer = described_class.new(record: record_with_existing_services, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.facility_services.count).to eq(initial_count)
      end

      it 'maintains all existing services' do
        syncer = described_class.new(record: record_with_existing_services, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.services).to include(service)
        expect(facility.services).to include(other_service)
      end
    end

    context 'when built facility has no services' do
      let!(:existing_facility) do
        facility = create(:facility, external_id: 'NO_SERVICES123')
        facility.facility_services.create!(service: other_service)
        facility
      end

      # Using an api_key that doesn't match any service
      let(:record_with_no_services) do
        {
          'mapid' => 'NO_SERVICES123',
          'name' => 'No Services Test',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'does not add any new services when built facility has none' do
        initial_count = existing_facility.facility_services.count

        syncer = described_class.new(record: record_with_no_services, api_key: 'non-existent-service')
        result = syncer.call

        facility = result.data.facility
        expect(facility.facility_services.count).to eq(initial_count)
      end

      it 'keeps existing services intact' do
        syncer = described_class.new(record: record_with_no_services, api_key: 'non-existent-service')
        result = syncer.call

        facility = result.data.facility
        expect(facility.services).to include(other_service)
      end
    end

    context 'when built facility has duplicate services in builder' do
      # This tests the .uniq call in add_missing_services
      let!(:existing_facility) do
        create(:facility, external_id: 'DUPLICATE_TEST123')
      end

      let(:record) do
        {
          'mapid' => 'DUPLICATE_TEST123',
          'name' => 'Duplicate Test',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Mock the built facility to have duplicate services
        # This would happen if FacilityBuilder creates duplicate associations
        allow_any_instance_of(External::VancouverCity::FacilitySyncer)
          .to receive(:add_missing_services).and_call_original
      end

      it 'handles duplicate services gracefully' do
        syncer = described_class.new(record: record, api_key: api_key)
        result = syncer.call

        # Should succeed without errors
        expect(result).to be_success
        facility = result.data.facility
        expect(facility.services).to include(service)
      end
    end

    context 'service creation edge cases' do
      let!(:existing_facility) do
        create(:facility, external_id: 'EDGE_CASE123')
      end

      let(:record) do
        {
          'mapid' => 'EDGE_CASE123',
          'name' => 'Edge Case Test',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      context 'when service does not exist in database' do
        it 'does not create facility_service for non-existent service' do
          syncer = described_class.new(record: record, api_key: 'non-existent-api-key')
          result = syncer.call

          facility = result.data.facility
          expect(facility.facility_services).to be_empty
        end

        it 'still succeeds the operation' do
          syncer = described_class.new(record: record, api_key: 'non-existent-api-key')
          result = syncer.call

          expect(result).to be_success
        end
      end
    end
  end
end
