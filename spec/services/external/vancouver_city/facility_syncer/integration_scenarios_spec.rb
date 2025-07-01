# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilitySyncer, 'integration scenarios', type: :service do
  let(:api_key) { 'drinking-fountains' }
  let(:service) { create(:water_fountain_service) }
  let(:secondary_service) { create(:service, key: 'public-washrooms') }

  before do
    service
    secondary_service
  end

  describe 'complex data integration' do
    context 'facility with comprehensive data' do
      let(:comprehensive_record) do
        {
          'mapid' => 'COMPREHENSIVE123',
          'name' => 'Downtown Community Fountain',
          'location' => 'Central Plaza',
          'geo_local_area' => 'Downtown Vancouver',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 },
          'phone' => '604-123-4567',
          'website' => 'https://vancouver.ca/fountains',
          'maintainer' => 'City of Vancouver',
          'in_operation' => 'Yes',
          'pet_friendly' => 'True'
        }
      end

      it 'creates facility with all available attributes' do
        syncer = described_class.new(record: comprehensive_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        facility = result.data.facility
        
        expect(facility.external_id).to eq('COMPREHENSIVE123')
        expect(facility.name).to eq('Downtown Community Fountain')
        expect(facility.address).to eq('Central Plaza, Downtown Vancouver')
        expect(facility.lat).to eq(49.2827)
        expect(facility.long).to eq(-123.1207)
        expect(facility.phone).to eq('604-123-4567')
        expect(facility.website).to eq('https://vancouver.ca/fountains')
        expect(facility.verified).to be true
        expect(facility.external?).to be true
      end

      it 'creates associated services, schedules, and welcomes' do
        syncer = described_class.new(record: comprehensive_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility
        
        # Services
        expect(facility.facility_services.count).to eq(1)
        expect(facility.services.first.key).to eq('water_fountain')
        
        # Schedules - should have open-all-day for all weekdays
        expect(facility.schedules.count).to eq(7)
        facility.schedules.each do |schedule|
          expect(schedule.open_all_day).to be true
          expect(schedule.closed_all_day).to be false
        end
        
        # Welcomes - should welcome all customer types
        expect(facility.facility_welcomes.count).to be > 0
      end
    end

    context 'facility with minimal valid data' do
      let(:minimal_record) do
        {
          'mapid' => 'MINIMAL123',
          'name' => 'Basic Fountain',
          'geo_point_2d' => { 'lat' => 49.0, 'lon' => -123.0 }
        }
      end

      it 'creates facility with defaults for missing optional fields' do
        syncer = described_class.new(record: minimal_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        facility = result.data.facility
        
        expect(facility.external_id).to eq('MINIMAL123')
        expect(facility.name).to eq('Basic Fountain')
        expect(facility.lat).to eq(49.0)
        expect(facility.long).to eq(-123.0)
        expect(facility.verified).to be true
        expect(facility.external?).to be true
      end
    end
  end

  describe 'edge case scenarios' do
    context 'facility with special characters in name' do
      let(:special_chars_record) do
        {
          'mapid' => 'SPECIAL123',
          'name' => "O'Brien's Water Fountain & Rest Area",
          'location' => 'Québec Street',
          'geo_local_area' => 'Mount Pleasant',
          'geo_point_2d' => { 'lat' => 49.2627, 'lon' => -123.1007 }
        }
      end

      it 'handles special characters correctly' do
        syncer = described_class.new(record: special_chars_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        facility = result.data.facility
        
        expect(facility.name).to eq("O'Brien's Water Fountain & Rest Area")
        expect(facility.address).to eq('Québec Street, Mount Pleasant')
      end
    end

    context 'facility at edge coordinates' do
      let(:edge_coords_record) do
        {
          'mapid' => 'EDGE123',
          'name' => 'Edge Case Fountain',
          'location' => 'Boundary Road',
          'geo_local_area' => 'Boundary',
          'geo_point_2d' => { 'lat' => 90.0, 'lon' => -180.0 } # Edge coordinates
        }
      end

      it 'handles edge coordinate values' do
        syncer = described_class.new(record: edge_coords_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        facility = result.data.facility
        
        expect(facility.lat).to eq(90.0)
        expect(facility.long).to eq(-180.0)
      end
    end
  end

  describe 'concurrent operation simulation' do
    context 'when the same external_id is processed simultaneously' do
      let(:concurrent_record1) do
        {
          'mapid' => 'CONCURRENT123',
          'name' => 'First Version Fountain',
          'location' => 'First Location',
          'geo_local_area' => 'Downtown',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      let(:concurrent_record2) do
        {
          'mapid' => 'CONCURRENT123',
          'name' => 'Second Version Fountain',
          'location' => 'Second Location',
          'geo_local_area' => 'Westside',
          'geo_point_2d' => { 'lat' => 49.2727, 'lon' => -123.1107 }
        }
      end

      it 'handles duplicate external_id creation gracefully' do
        # First sync
        syncer1 = described_class.new(record: concurrent_record1, api_key: api_key)
        result1 = syncer1.call

        expect(result1).to be_success
        expect(result1.data.operation).to eq(:create)
        
        # Second sync with same external_id but different data
        syncer2 = described_class.new(record: concurrent_record2, api_key: api_key)
        result2 = syncer2.call

        expect(result2).to be_success
        expect(result2.data.operation).to eq(:external_update)
        
        # Verify final state
        facility = Facility.find_by(external_id: 'CONCURRENT123')
        expect(facility.name).to eq('Second Version Fountain')
        expect(facility.address).to eq('Second Location, Westside')
      end
    end
  end

  describe 'data consistency verification' do
    let(:consistency_record) do
      {
        'mapid' => 'CONSISTENCY123',
        'name' => 'Consistency Test Fountain',
        'location' => 'Test Park',
        'geo_local_area' => 'Test Area',
        'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
      }
    end

    it 'ensures data integrity across all related models' do
      syncer = described_class.new(record: consistency_record, api_key: api_key)
      result = syncer.call

      expect(result).to be_success
      facility = result.data.facility
      
      # Verify facility
      expect(facility).to be_persisted
      expect(facility.external_id).to eq('CONSISTENCY123')
      
      # Verify services
      expect(facility.facility_services.count).to eq(1)
      expect(facility.facility_services.first.service.key).to eq('water_fountain')
      
      # Verify schedules
      expect(facility.schedules.count).to eq(7)
      facility.schedules.each do |schedule|
        expect(schedule.facility_id).to eq(facility.id)
        expect(schedule).to be_persisted
      end
      
      # Verify welcomes
      expect(facility.facility_welcomes.count).to be > 0
      facility.facility_welcomes.each do |welcome|
        expect(welcome.facility_id).to eq(facility.id)
        expect(welcome).to be_persisted
      end
    end
  end
end
