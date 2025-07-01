# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilitySyncer, 'create operation', type: :service do
  let(:api_key) { 'drinking-fountains' }
  let(:service) { create(:water_fountain_service) }

  before { service } # Ensure service exists

  describe 'create operation (:create)' do
    context 'when built facility is valid' do
      let(:valid_record) do
        {
          'mapid' => 'CREATE123',
          'name' => 'New Valid Fountain',
          'location' => 'Valid Park',
          'geo_local_area' => 'Downtown',
          'phone' => '604-123-4567',
          'website' => 'https://vancouver.ca',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'saves the facility successfully' do
        expect do
          syncer = described_class.new(record: valid_record, api_key: api_key)
          syncer.call
        end.to change(Facility, :count).by(1)
      end

      it 'returns success result with operation: :create' do
        syncer = described_class.new(record: valid_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        expect(result.data.operation).to eq(:create)
        expect(result.errors).to be_empty
      end

      it 'sets result_facility to built_facility' do
        syncer = described_class.new(record: valid_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility).to be_persisted
        expect(facility.name).to eq('New Valid Fountain')
        expect(facility.external_id).to eq('CREATE123')
        expect(facility.verified).to be true
      end

      it 'creates facility with all expected attributes' do
        syncer = described_class.new(record: valid_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.name).to eq('New Valid Fountain')
        expect(facility.address).to eq('Valid Park, Downtown')
        expect(facility.phone).to eq('604-123-4567')
        expect(facility.website).to eq('https://vancouver.ca')
        expect(facility.lat).to eq(49.2827)
        expect(facility.long).to eq(-123.1207)
        expect(facility.verified).to be true
        expect(facility.external_id).to eq('CREATE123')
      end

      it 'creates facility services' do
        syncer = described_class.new(record: valid_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility.facility_services.count).to eq(1)
        expect(facility.services).to include(service)
      end

      it 'logs creation message with external_id' do
        expect(Rails.logger).to receive(:info).with("Creating new facility with external_id 'CREATE123'")

        syncer = described_class.new(record: valid_record, api_key: api_key)
        syncer.call
      end
    end

    context 'when FacilityBuilder fails due to invalid data' do
      let(:invalid_record) do
        {
          'mapid' => 'INVALID123',
          'name' => '', # Empty name causes FacilityBuilder to fail
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'does not save facility' do
        expect do
          syncer = described_class.new(record: invalid_record, api_key: api_key)
          syncer.call
        end.not_to change(Facility, :count)
      end

      it 'adds validation errors to errors array' do
        syncer = described_class.new(record: invalid_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/can't be blank/i))
      end

      it 'sets result_facility to nil' do
        syncer = described_class.new(record: invalid_record, api_key: api_key)
        result = syncer.call

        expect(result.data.facility).to be_nil
      end

      it 'returns early with operation: nil when FacilityBuilder fails' do
        syncer = described_class.new(record: invalid_record, api_key: api_key)
        result = syncer.call

        expect(result.data.operation).to be_nil  # FacilityBuilder fails before operation is determined
        expect(result).to be_failed
      end
    end

    context 'when save! raises other StandardError' do
      let(:valid_record) do
        {
          'mapid' => 'ERROR123',
          'name' => 'Error Test Fountain',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Simulate a database connection error or similar
        allow_any_instance_of(Facility).to receive(:save!).and_raise(StandardError.new('Database connection lost'))
      end

      it 'catches exception and adds generic error message' do
        syncer = described_class.new(record: valid_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Unexpected error during facility sync:/))
      end

      it 'includes original error message' do
        syncer = described_class.new(record: valid_record, api_key: api_key)
        result = syncer.call

        expect(result.errors.first).to include('Database connection lost')
      end

      it 'does not save facility on failure' do
        expect do
          syncer = described_class.new(record: valid_record, api_key: api_key)
          syncer.call
        end.not_to change(Facility, :count)
      end

      it 'does not create any related records on failure' do
        expect do
          syncer = described_class.new(record: valid_record, api_key: api_key)
          syncer.call
        end.not_to change(FacilityService, :count)
      end
    end

    context 'when save! raises ActiveRecord::RecordInvalid' do
      let(:invalid_save_record) do
        {
          'mapid' => 'INVALID_SAVE123',
          'name' => 'Valid Name',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # Simulate a validation error during save
        allow_any_instance_of(Facility).to receive(:save!).and_raise(
          ActiveRecord::RecordInvalid.new(build(:facility))
        )
      end

      it 'catches RecordInvalid and adds error message' do
        syncer = described_class.new(record: invalid_save_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Failed to save facility:/))
      end

      it 'does not create facility record on validation failure' do
        expect do
          syncer = described_class.new(record: invalid_save_record, api_key: api_key)
          syncer.call
        end.not_to change(Facility, :count)
      end

      it 'does not create any related records on validation failure' do
        expect do
          syncer = described_class.new(record: invalid_save_record, api_key: api_key)
          syncer.call
        end.not_to change(FacilityService, :count)
      end
    end

    context 'when service creation fails' do
      let(:service_fail_record) do
        {
          'mapid' => 'SERVICE_FAIL123',
          'name' => 'Service Fail Test',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      before do
        # For create operations, service associations are built in memory by FacilityBuilder
        # and saved together with the facility. To simulate failure, we need to make 
        # the facility save fail due to a constraint on the associations.
        allow_any_instance_of(Facility).to receive(:save!).and_raise(
          ActiveRecord::RecordInvalid.new(build(:facility, name: 'Service validation failed'))
        )
      end

      it 'rolls back facility creation when facility save fails' do
        expect do
          syncer = described_class.new(record: service_fail_record, api_key: api_key)
          syncer.call
        end.not_to change(Facility, :count)
      end

      it 'does not create any service records when transaction fails' do
        expect do
          syncer = described_class.new(record: service_fail_record, api_key: api_key)
          syncer.call
        end.not_to change(FacilityService, :count)
      end

      it 'does not create any schedule records when transaction fails' do
        expect do
          syncer = described_class.new(record: service_fail_record, api_key: api_key)
          syncer.call
        end.not_to change(FacilitySchedule, :count)
      end

      it 'returns failed result with proper error message' do
        syncer = described_class.new(record: service_fail_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Failed to save facility:/))
      end
    end

    context 'database record creation on success' do
      let(:success_record) do
        {
          'mapid' => 'SUCCESS123',
          'name' => 'Success Test Fountain',
          'location' => 'Success Park',
          'geo_local_area' => 'Downtown',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'creates facility with all related records atomically' do
        syncer = described_class.new(record: success_record, api_key: api_key)
        
        expect { syncer.call }.to change { Facility.count }.by(1)
          .and change { FacilityService.count }.by(1)
          .and change { FacilitySchedule.count }.by(7) # 7 days of the week
          .and change { FacilityWelcome.count }.by_at_least(1)
      end

      it 'creates facility with correct attributes and relationships' do
        syncer = described_class.new(record: success_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        expect(facility).to be_persisted
        expect(facility.external_id).to eq('SUCCESS123')
        expect(facility.name).to eq('Success Test Fountain')
        expect(facility.verified).to be true
        
        # Verify related records are created
        expect(facility.facility_services.count).to eq(1)
        expect(facility.facility_services.first.service).to eq(service)
        expect(facility.schedules.count).to eq(7)
        expect(facility.facility_welcomes.count).to be > 0
      end

      it 'ensures all database records are properly linked' do
        syncer = described_class.new(record: success_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        
        # Verify foreign key relationships
        expect(facility.facility_services.all? { |fs| fs.facility_id == facility.id }).to be true
        expect(facility.schedules.all? { |s| s.facility_id == facility.id }).to be true
        expect(facility.facility_welcomes.all? { |fw| fw.facility_id == facility.id }).to be true
      end
    end
  end
end
