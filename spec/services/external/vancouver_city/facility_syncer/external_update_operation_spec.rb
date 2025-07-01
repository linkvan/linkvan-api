# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilitySyncer, 'external update operation', type: :service do
  let(:api_key) { 'drinking-fountains' }
  let(:service) { create(:service, key: api_key) }
  let(:other_service) { create(:service, key: 'public-washrooms') }

  before do
    service
    other_service
  end

  describe 'external_update operation (:external_update)' do
    context 'when update succeeds' do
      let!(:existing_external_facility) do
        create(:facility,
               external_id: 'EXT_UPDATE123',
               name: 'Old Name',
               address: 'Old Address',
               lat: 49.0000,
               long: -123.0000,
               verified: false)
      end

      let(:update_record) do
        {
          'mapid' => 'EXT_UPDATE123',
          'name' => 'Updated Fountain Name',
          'location' => 'Updated Park',
          'geo_local_area' => 'Updated Area',
          'phone' => '604-999-8888',
          'geo_point_2d' => { 'lat' => 49.9999, 'lon' => -123.9999 }
        }
      end

      it 'updates facility attributes' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.name).to eq('Updated Fountain Name')
        expect(facility.address).to eq('Updated Park, Updated Area')
        expect(facility.lat).to eq(49.9999)
        expect(facility.long).to eq(-123.9999)
        expect(facility.verified).to be true
      end

      it 'adds missing services' do
        expect(existing_external_facility.services).not_to include(service)

        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.services).to include(service)
      end

      it 'returns existing facility in result' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result.data.facility.id).to eq(existing_external_facility.id)
        expect(result.data.operation).to eq(:external_update)
      end

      it 'logs update message with external_id' do
        expect(Rails.logger).to receive(:info).with("Facility with external_id 'EXT_UPDATE123' already exists, updating services")

        syncer = described_class.new(record: update_record, api_key: api_key)
        syncer.call
      end

      it 'returns success result' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        expect(result.errors).to be_empty
      end

      it 'does not create new facility' do
        expect do
          syncer = described_class.new(record: update_record, api_key: api_key)
          syncer.call
        end.not_to change(Facility, :count)
      end
    end

    context 'when facility already has the service' do
      let!(:existing_external_facility) do
        facility = create(:facility,
                         external_id: 'EXT_HAS_SERVICE123',
                         name: 'Fountain with Service')
        facility.facility_services.create!(service: service)
        facility
      end

      let(:update_record) do
        {
          'mapid' => 'EXT_HAS_SERVICE123',
          'name' => 'Updated Name',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'does not duplicate existing services' do
        initial_service_count = existing_external_facility.facility_services.count
        
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.facility_services.count).to eq(initial_service_count)
      end

      it 'still updates facility attributes' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.name).to eq('Updated Name')
      end
    end

    context 'when update! raises ActiveRecord::RecordInvalid during attribute update' do
      let!(:existing_external_facility) do
        create(:facility,
               external_id: 'EXT_INVALID123',
               name: 'Test Facility')
      end

      let(:update_record) do
        {
          'mapid' => 'EXT_INVALID123',
          'name' => 'Updated Name',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Simulate a validation error during update
        allow_any_instance_of(Facility).to receive(:update!).and_raise(
          ActiveRecord::RecordInvalid.new(existing_external_facility)
        )
      end

      it 'catches exception during attribute update' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Failed to save facility:/))
      end
    end

    context 'when create! raises ActiveRecord::RecordInvalid during service creation' do
      let!(:existing_external_facility) do
        create(:facility,
               external_id: 'EXT_SERVICE_ERROR123',
               name: 'Test Facility')
      end

      let(:update_record) do
        {
          'mapid' => 'EXT_SERVICE_ERROR123',
          'name' => 'Updated Name',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Simulate a constraint violation when creating facility service
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy)
          .to receive(:create!).and_raise(
            ActiveRecord::RecordInvalid.new(FacilityService.new)
          )
      end

      it 'catches exception during service creation' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Failed to save facility:/))
      end
    end

    context 'when update raises other StandardError' do
      let!(:existing_external_facility) do
        create(:facility,
               external_id: 'EXT_STD_ERROR123',
               name: 'Test Facility')
      end

      let(:update_record) do
        {
          'mapid' => 'EXT_STD_ERROR123',
          'name' => 'Updated Name',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Force service creation to fail during add_missing_services
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy)
          .to receive(:create!).and_raise(StandardError.new('Service creation failed'))
      end

      it 'catches and handles generic errors' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Unexpected error during facility sync:/))
        expect(result.errors.first).to include('Service creation failed')
      end

      it 'does not update facility attributes on error' do
        original_name = existing_external_facility.name
        original_address = existing_external_facility.address
        
        syncer = described_class.new(record: update_record, api_key: api_key)
        syncer.call

        existing_external_facility.reload
        expect(existing_external_facility.name).to eq(original_name)
        expect(existing_external_facility.address).to eq(original_address)
      end

      it 'does not create any new service records on error' do
        expect do
          syncer = described_class.new(record: update_record, api_key: api_key)
          syncer.call
        end.not_to change(FacilityService, :count)
      end
    end

    context 'database record updates on success' do
      let!(:external_facility_with_data) do
        facility = create(:facility,
                         external_id: 'DB_UPDATE123',
                         name: 'Original Name',
                         address: 'Original Address',
                         lat: 49.0000,
                         long: -123.0000,
                         verified: false)
        
        # Add existing service from different API
        facility.facility_services.create!(service: other_service)
        facility
      end

      let(:comprehensive_update_record) do
        {
          'mapid' => 'DB_UPDATE123',
          'name' => 'Completely Updated Name',
          'location' => 'New Location',
          'geo_local_area' => 'New Area',
          'phone' => '604-555-1234',
          'website' => 'https://updated.example.com',
          'geo_point_2d' => { 'lat' => 49.5555, 'lon' => -123.5555 }
        }
      end

      it 'updates all facility attributes correctly' do
        syncer = described_class.new(record: comprehensive_update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        # Only these attributes are updated in external_update operations
        expect(facility.name).to eq('Completely Updated Name')
        expect(facility.address).to eq('New Location, New Area')
        expect(facility.lat).to eq(49.5555)
        expect(facility.long).to eq(-123.5555)
        expect(facility.verified).to be true
        expect(facility.external_id).to eq('DB_UPDATE123') # Should remain unchanged
        
        # These attributes are NOT updated in external_update operations
        expect(facility.phone).to eq('123') # Original value from factory
        expect(facility.website).to eq('www.facility.test') # Original value from factory
      end

      it 'adds new service without removing existing ones' do
        initial_service_count = external_facility_with_data.facility_services.count
        
        syncer = described_class.new(record: comprehensive_update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.facility_services.count).to eq(initial_service_count + 1)
        expect(facility.services).to include(service) # New service added
        expect(facility.services).to include(other_service) # Existing service preserved
      end

      it 'maintains referential integrity during updates' do
        syncer = described_class.new(record: comprehensive_update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        
        # Verify all related records still reference the correct facility
        expect(facility.facility_services.all? { |fs| fs.facility_id == facility.id }).to be true
        expect(facility.schedules.all? { |s| s.facility_id == facility.id }).to be true
        expect(facility.facility_welcomes.all? { |fw| fw.facility_id == facility.id }).to be true
      end

      it 'does not create duplicate services for same API key' do
        # First update
        syncer1 = described_class.new(record: comprehensive_update_record, api_key: api_key)
        syncer1.call
        
        initial_count = external_facility_with_data.reload.facility_services.count
        
        # Second update with same API key
        syncer2 = described_class.new(record: comprehensive_update_record, api_key: api_key)
        syncer2.call
        
        external_facility_with_data.reload
        expect(external_facility_with_data.facility_services.count).to eq(initial_count)
      end
    end

    context 'transaction rollback on failure' do
      let!(:rollback_facility) do
        create(:facility,
               external_id: 'ROLLBACK123',
               name: 'Rollback Test',
               address: 'Original Address',
               verified: false)
      end

      let(:rollback_record) do
        {
          'mapid' => 'ROLLBACK123',
          'name' => 'Updated Name',
          'location' => 'Updated Location',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Force failure after attribute update but before service creation
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy)
          .to receive(:create!).and_raise(StandardError.new('Service creation failed'))
      end

      it 'rolls back attribute changes when service creation fails' do
        original_name = rollback_facility.name
        original_address = rollback_facility.address
        original_verified = rollback_facility.verified
        
        syncer = described_class.new(record: rollback_record, api_key: api_key)
        syncer.call

        rollback_facility.reload
        expect(rollback_facility.name).to eq(original_name)
        expect(rollback_facility.address).to eq(original_address)
        expect(rollback_facility.verified).to eq(original_verified)
      end

      it 'does not create any service records when transaction fails' do
        expect do
          syncer = described_class.new(record: rollback_record, api_key: api_key)
          syncer.call
        end.not_to change(FacilityService, :count)
      end

      it 'maintains database consistency after rollback' do
        original_service_count = rollback_facility.facility_services.count
        
        syncer = described_class.new(record: rollback_record, api_key: api_key)
        syncer.call

        rollback_facility.reload
        expect(rollback_facility.facility_services.count).to eq(original_service_count)
      end
    end
  end
end
