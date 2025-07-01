# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilitySyncer, 'internal update operation', type: :service do
  let(:api_key) { 'drinking-fountains' }
  let(:service) { create(:service, key: api_key) }
  let(:other_service) { create(:service, key: 'public-washrooms') }

  before do
    service
    other_service
  end

  describe 'internal_update operation (:internal_update)' do
    context 'when update succeeds' do
      let!(:existing_internal_facility) do
        create(:facility,
               external_id: nil,
               name: 'Internal Fountain',
               address: 'Original Address',
               lat: 49.1111,
               long: -123.1111,
               verified: false)
      end

      let(:update_record) do
        {
          'mapid' => 'NEW_EXT_ID123',
          'name' => 'Internal Fountain', # Matches by name
          'location' => 'Different Location',
          'geo_local_area' => 'Different Area',
          'geo_point_2d' => { 'lat' => 49.9999, 'lon' => -123.9999 }
        }
      end

      it 'adds missing services only' do
        expect(existing_internal_facility.services).not_to include(service)

        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.services).to include(service)
      end

      it 'does not update facility attributes' do
        original_name = existing_internal_facility.name
        original_address = existing_internal_facility.address
        original_lat = existing_internal_facility.lat
        original_long = existing_internal_facility.long
        original_verified = existing_internal_facility.verified

        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.name).to eq(original_name)
        expect(facility.address).to eq(original_address)
        expect(facility.lat).to eq(original_lat)
        expect(facility.long).to eq(original_long)
        expect(facility.verified).to eq(original_verified)
      end

      it 'returns existing facility in result' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result.data.facility.id).to eq(existing_internal_facility.id)
        expect(result.data.operation).to eq(:internal_update)
      end

      it 'logs warning message with facility name' do
        expect(Rails.logger).to receive(:warn).with("Facility with name 'Internal Fountain' already exists internally, adding services")

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
      let!(:existing_internal_facility) do
        facility = create(:facility,
                         external_id: nil,
                         name: 'Fountain with Service',
                         verified: false)
        facility.facility_services.create!(service: service)
        facility
      end

      let(:update_record) do
        {
          'mapid' => 'SOME_ID123',
          'name' => 'Fountain with Service',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'does not duplicate existing services' do
        initial_service_count = existing_internal_facility.facility_services.count

        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.facility_services.count).to eq(initial_service_count)
      end

      it 'still succeeds even with no new services to add' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        expect(result.data.operation).to eq(:internal_update)
      end
    end

    context 'when service creation raises ActiveRecord::RecordInvalid' do
      let!(:existing_internal_facility) do
        create(:facility,
               external_id: nil,
               name: 'Service Error Fountain',
               verified: false)
      end

      let(:update_record) do
        {
          'mapid' => 'ERROR_ID123',
          'name' => 'Service Error Fountain',
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

      it 'catches exception and adds error message' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Failed to save facility:/))
      end
    end

    context 'when update raises other StandardError' do
      let!(:existing_internal_facility) do
        create(:facility,
               external_id: nil,
               name: 'Generic Error Fountain',
               verified: false)
      end

      let(:update_record) do
        {
          'mapid' => 'GENERIC_ERROR123',
          'name' => 'Generic Error Fountain',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Simulate a database connection error during service creation
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy)
          .to receive(:create!).and_raise(
            StandardError.new('Database connection failed')
          )
      end

      it 'catches and handles generic errors' do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Unexpected error during facility sync:/))
        expect(result.errors.first).to include('Database connection failed')
      end
    end

    context 'when record would create new facility but matches internal by name' do
      let!(:existing_internal_facility) do
        create(:facility,
               external_id: nil,
               name: 'Exact Name Match',
               verified: false)
      end

      let(:new_record_matching_name) do
        {
          'mapid' => 'COMPLETELY_NEW_ID',
          'name' => 'Exact Name Match', # Same name but would have different external_id
          'location' => 'New Location',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'treats as internal update rather than create' do
        syncer = described_class.new(record: new_record_matching_name, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to eq(:internal_update)
        expect(result.data.facility.id).to eq(existing_internal_facility.id)
      end

      it 'does not change facility external_id' do
        syncer = described_class.new(record: new_record_matching_name, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.external_id).to be_nil # Should remain nil
      end
    end

    context 'database record updates on success' do
      let!(:internal_facility_with_services) do
        facility = create(:facility,
                         external_id: nil,
                         name: 'Internal Service Test',
                         address: 'Original Internal Address',
                         verified: false)
        
        # Add existing service from different API
        facility.facility_services.create!(service: other_service)
        facility
      end

      let(:internal_service_update_record) do
        {
          'mapid' => 'NEW_EXTERNAL_ID456',
          'name' => 'Internal Service Test', # Matches by name
          'location' => 'Different Location', # Should NOT update
          'geo_point_2d' => { 'lat' => 49.9999, 'lon' => -123.9999 } # Should NOT update
        }
      end

      it 'adds new service without modifying facility attributes' do
        original_name = internal_facility_with_services.name
        original_address = internal_facility_with_services.address
        original_lat = internal_facility_with_services.lat
        original_long = internal_facility_with_services.long
        original_verified = internal_facility_with_services.verified
        original_external_id = internal_facility_with_services.external_id
        
        syncer = described_class.new(record: internal_service_update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        
        # Verify attributes remain unchanged
        expect(facility.name).to eq(original_name)
        expect(facility.address).to eq(original_address)
        expect(facility.lat).to eq(original_lat)
        expect(facility.long).to eq(original_long)
        expect(facility.verified).to eq(original_verified)
        expect(facility.external_id).to eq(original_external_id)
      end

      it 'adds new service while preserving existing ones' do
        initial_service_count = internal_facility_with_services.facility_services.count
        
        syncer = described_class.new(record: internal_service_update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.facility_services.count).to eq(initial_service_count + 1)
        expect(facility.services).to include(service) # New service added
        expect(facility.services).to include(other_service) # Existing service preserved
      end

      it 'maintains referential integrity when adding services' do
        syncer = described_class.new(record: internal_service_update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        
        # Verify all services belong to the correct facility
        expect(facility.facility_services.all? { |fs| fs.facility_id == facility.id }).to be true
        
        # Verify the new service was added correctly
        new_service_record = facility.facility_services.find_by(service: service)
        expect(new_service_record).to be_present
        expect(new_service_record.facility_id).to eq(facility.id)
      end

      it 'does not create duplicate services for same API key' do
        # First update
        syncer1 = described_class.new(record: internal_service_update_record, api_key: api_key)
        syncer1.call
        
        initial_count = internal_facility_with_services.reload.facility_services.count
        
        # Second update with same API key
        syncer2 = described_class.new(record: internal_service_update_record, api_key: api_key)
        syncer2.call
        
        internal_facility_with_services.reload
        expect(internal_facility_with_services.facility_services.count).to eq(initial_count)
      end
    end

    context 'transaction rollback on failure' do
      let!(:rollback_internal_facility) do
        facility = create(:facility,
                         external_id: nil,
                         name: 'Rollback Internal Test',
                         verified: false)
        
        # Add existing service
        facility.facility_services.create!(service: other_service)
        facility
      end

      let(:rollback_internal_record) do
        {
          'mapid' => 'ROLLBACK_INTERNAL123',
          'name' => 'Rollback Internal Test',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Force service creation to fail
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy)
          .to receive(:create!).and_raise(StandardError.new('Service creation failed'))
      end

      it 'does not create any service records when transaction fails' do
        original_service_count = rollback_internal_facility.facility_services.count
        
        expect do
          syncer = described_class.new(record: rollback_internal_record, api_key: api_key)
          syncer.call
        end.not_to change(FacilityService, :count)
        
        rollback_internal_facility.reload
        expect(rollback_internal_facility.facility_services.count).to eq(original_service_count)
      end

      it 'maintains existing facility state when service addition fails' do
        original_attributes = rollback_internal_facility.attributes
        original_service_ids = rollback_internal_facility.facility_services.pluck(:service_id)
        
        syncer = described_class.new(record: rollback_internal_record, api_key: api_key)
        result = syncer.call

        rollback_internal_facility.reload
        
        # Verify facility attributes unchanged
        expect(rollback_internal_facility.attributes).to eq(original_attributes)
        
        # Verify existing services unchanged
        expect(rollback_internal_facility.facility_services.pluck(:service_id)).to match_array(original_service_ids)
        
        expect(result).to be_failed
      end

      it 'does not affect other facilities when one fails' do
        other_facility = create(:facility, external_id: nil, name: 'Other Facility')
        
        expect do
          syncer = described_class.new(record: rollback_internal_record, api_key: api_key)
          syncer.call
        end.not_to change { other_facility.reload.facility_services.count }
      end
    end

    context 'validation error handling' do
      let!(:validation_internal_facility) do
        create(:facility,
               external_id: nil,
               name: 'Validation Test Facility',
               verified: false)
      end

      let(:validation_record) do
        {
          'mapid' => 'VALIDATION123',
          'name' => 'Validation Test Facility',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Simulate validation error during service creation
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy)
          .to receive(:create!).and_raise(
            ActiveRecord::RecordInvalid.new(FacilityService.new)
          )
      end

      it 'does not modify facility when service validation fails' do
        original_service_count = validation_internal_facility.facility_services.count
        original_updated_at = validation_internal_facility.updated_at
        
        syncer = described_class.new(record: validation_record, api_key: api_key)
        syncer.call

        validation_internal_facility.reload
        expect(validation_internal_facility.facility_services.count).to eq(original_service_count)
        expect(validation_internal_facility.updated_at).to eq(original_updated_at)
      end

      it 'returns proper error information for validation failures' do
        syncer = described_class.new(record: validation_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Failed to save facility:/))
        expect(result.data.operation).to eq(:internal_update)
        expect(result.data.facility).to be_nil # Should be nil when operation fails
      end
    end
  end
end
