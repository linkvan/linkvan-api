# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilityBuilder, type: :service do
  let(:valid_api_key) { 'drinking-fountains' }

  let(:valid_record) do
    {
      'name' => 'Test Fountain',
      'location' => 'Test Park',
      'geo_local_area' => 'Downtown',
      'phone' => '604-123-4567',
      'website' => 'https://vancouver.ca',
      'maintainer' => 'Parks Department',
      'in_operation' => 'Yes',
      'pet_friendly' => 'Yes',
      'geom' => {
        'geometry' => {
          'coordinates' => [-123.1207, 49.2827]
        }
      }
    }
  end

  let(:minimal_record) do
    {
      'name' => 'Minimal Fountain',
      'geo_point_2d' => {
        'lat' => 49.2827,
        'lon' => -123.1207
      }
    }
  end

  describe '#initialize' do
    it 'initializes with valid parameters' do
      builder = described_class.new(record: valid_record, api_key: valid_api_key)
      
      expect(builder.record).to eq(valid_record)
      expect(builder.api_key).to eq(valid_api_key)
    end
  end

  describe '#validate' do
    context 'with valid parameters' do
      let(:builder) { described_class.new(record: valid_record, api_key: valid_api_key) }

      it 'returns empty errors array' do
        expect(builder.validate).to be_blank
      end

      it 'is valid' do
        expect(builder).to be_valid
      end
    end

    context 'with nil record' do
      let(:builder) { described_class.new(record: nil, api_key: valid_api_key) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Record is required')
      end
    end

    context 'with non-hash record' do
      let(:builder) { described_class.new(record: 'invalid', api_key: valid_api_key) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Record must be a Hash')
      end
    end
  end

  describe '#call' do
    let(:service) { create(:service, key: valid_api_key) }

    before do
      service # Ensure service exists
    end

    context 'with valid parameters and complete record' do
      let(:builder) { described_class.new(record: valid_record, api_key: valid_api_key) }

      it 'returns successful result' do
        result = builder.call
        
        expect(result).to be_success
        expect(result.errors).to be_blank
        expect(result.data[:facility]).to be_a(Facility)
      end

      it 'builds facility with correct attributes' do
        result = builder.call
        facility = result.data[:facility]

        expect(facility.name).to eq('Test Fountain')
        expect(facility.address).to eq('Test Park, Downtown')
        expect(facility.phone).to eq('604-123-4567')
        expect(facility.website).to eq('https://vancouver.ca')
        expect(facility.lat).to eq(49.2827)
        expect(facility.long).to eq(-123.1207)
        expect(facility.verified).to be true
      end

      it 'builds notes from multiple fields' do
        result = builder.call
        facility = result.data[:facility]

        expect(facility.notes).to include('Maintained by: Parks Department')
        expect(facility.notes).to include('Operation: Yes')
        expect(facility.notes).to include('Pet friendly: Yes')
      end

      it 'associates correct service' do
        result = builder.call
        facility = result.data[:facility]

        expect(facility.facility_services.size).to eq(1)
        expect(facility.facility_services.first.service).to eq(service)
      end

      it 'creates facility welcomes for all customers' do
        result = builder.call
        facility = result.data[:facility]

        expect(facility.facility_welcomes).not_to be_blank
        # Test that welcomes are created (exact count depends on FacilityWelcome.all_customers)
      end

      it 'creates schedules for all weekdays' do
        result = builder.call
        facility = result.data[:facility]

        expect(facility.schedules.size).to eq(7)  # All weekdays
        facility.schedules.each do |schedule|
          expect(schedule.closed_all_day).to be false
          expect(schedule.open_all_day).to be true
        end
      end

      describe 'schedule business logic' do
        it 'creates exactly one schedule for each day of the week' do
          result = builder.call
          facility = result.data[:facility]

          # Test that we have all 7 days
          expect(facility.schedules.size).to eq(7)
          
          # Test that each day is covered exactly once
          week_days = facility.schedules.map(&:week_day)
          expect(week_days.sort).to eq(FacilitySchedule.week_days.keys.sort)
        end

        it 'sets all schedules to open_all_day = true and closed_all_day = false' do
          result = builder.call
          facility = result.data[:facility]

          facility.schedules.each do |schedule|
            expect(schedule.open_all_day).to be(true), "Expected #{schedule.week_day} to be open_all_day"
            expect(schedule.closed_all_day).to be(false), "Expected #{schedule.week_day} not to be closed_all_day"
          end
        end

        it 'creates schedules without time slots (consistent with open_all_day)' do
          result = builder.call
          facility = result.data[:facility]

          facility.schedules.each do |schedule|
            expect(schedule.time_slots).to be_blank, "Expected #{schedule.week_day} to have no time slots when open_all_day"
          end
        end

        it 'creates valid schedule objects that pass model validations' do
          result = builder.call
          facility = result.data[:facility]

          facility.schedules.each do |schedule|
            expect(schedule).to be_valid, "Expected #{schedule.week_day} schedule to be valid: #{schedule.errors.full_messages}"
          end
        end

        it 'sets schedule availability to :open for all days' do
          result = builder.call
          facility = result.data[:facility]

          facility.schedules.each do |schedule|
            expect(schedule.availability).to eq(:open), "Expected #{schedule.week_day} availability to be :open"
          end
        end

        context 'when no fields are provided for schedules' do
          it 'still creates open_all_day schedules for all weekdays' do
            # Test with minimal record that has no schedule-related fields
            minimal_builder = described_class.new(record: minimal_record, api_key: valid_api_key)
            result = minimal_builder.call
            facility = result.data[:facility]

            expect(facility.schedules.size).to eq(7)
            facility.schedules.each do |schedule|
              expect(schedule.open_all_day).to be true
              expect(schedule.closed_all_day).to be false
            end
          end
        end

        context 'business requirement verification' do
          it 'ensures imported facilities are always accessible 24/7' do
            result = builder.call
            facility = result.data[:facility]

            # Verify that the facility is accessible any day of the week, any time
            FacilitySchedule.week_days.each_key do |day|
              schedule = facility.schedules.find { |s| s.week_day == day.to_s }
              expect(schedule).to be_present, "Missing schedule for #{day}"
              expect(schedule.open_all_day).to be(true), "Facility should be accessible 24/7 on #{day}"
              expect(schedule.closed_all_day).to be(false), "Facility should not be closed on #{day}"
            end
          end
        end
      end
    end

    context 'with minimal record' do
      let(:builder) { described_class.new(record: minimal_record, api_key: valid_api_key) }

      it 'returns successful result' do
        result = builder.call
        
        expect(result).to be_success
        expect(result.data[:facility]).to be_a(Facility)
      end

      it 'builds facility with minimal data' do
        result = builder.call
        facility = result.data[:facility]

        expect(facility.name).to eq('Minimal Fountain')
        expect(facility.lat).to eq(49.2827)
        expect(facility.long).to eq(-123.1207)
        expect(facility.address).to be_nil
        expect(facility.phone).to be_nil
        expect(facility.website).to be_nil
      end
    end

    context 'with geo_point_2d coordinates' do
      let(:record_with_geo_point) do
        {
          'name' => 'Geo Point Fountain',
          'geo_point_2d' => {
            'lat' => 49.2827,
            'lon' => -123.1207
          }
        }
      end
      let(:builder) { described_class.new(record: record_with_geo_point, api_key: valid_api_key) }

      it 'extracts coordinates from geo_point_2d' do
        result = builder.call
        facility = result.data[:facility]

        expect(facility.lat).to eq(49.2827)
        expect(facility.long).to eq(-123.1207)
      end
    end

    context 'with geometry coordinates' do
      let(:record_with_geometry) do
        {
          'name' => 'Geometry Fountain',
          'geom' => {
            'geometry' => {
              'coordinates' => [-123.1207, 49.2827]  # GeoJSON format: [longitude, latitude]
            }
          }
        }
      end
      let(:builder) { described_class.new(record: record_with_geometry, api_key: valid_api_key) }

      it 'extracts coordinates from geometry in correct order' do
        result = builder.call
        facility = result.data[:facility]

        expect(facility.lat).to eq(49.2827)   # Latitude from coordinates[1]
        expect(facility.long).to eq(-123.1207) # Longitude from coordinates[0]
      end
    end

    context 'with special characters in name' do
      let(:record_with_special_chars) do
        {
          'name' => "Test\\nFountain\nWith\n\nSpecial   Chars",
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end
      let(:builder) { described_class.new(record: record_with_special_chars, api_key: valid_api_key) }

      it 'cleans name by removing special characters and extra whitespace' do
        result = builder.call
        facility = result.data[:facility]

        expect(facility.name).to eq('Test Fountain With Special Chars')
      end
    end

    context 'with phone field variations' do
      let(:record_with_phone_number) do
        {
          'name' => 'Phone Test',
          'phone_number' => '604-555-1234',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end
      let(:record_with_contact_phone) do
        {
          'name' => 'Contact Phone Test',
          'contact_phone' => '604-555-5678',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'extracts phone from phone_number field' do
        builder = described_class.new(record: record_with_phone_number, api_key: valid_api_key)
        result = builder.call
        facility = result.data[:facility]

        expect(facility.phone).to eq('604-555-1234')
      end

      it 'extracts phone from contact_phone field' do
        builder = described_class.new(record: record_with_contact_phone, api_key: valid_api_key)
        result = builder.call
        facility = result.data[:facility]

        expect(facility.phone).to eq('604-555-5678')
      end
    end

    context 'with website field variations' do
      let(:record_with_url) do
        {
          'name' => 'URL Test',
          'url' => 'https://example.com',
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end

      it 'extracts website from url field' do
        builder = described_class.new(record: record_with_url, api_key: valid_api_key)
        result = builder.call
        facility = result.data[:facility]

        expect(facility.website).to eq('https://example.com')
      end
    end

    context 'with no coordinates' do
      let(:record_without_coords) do
        {
          'name' => 'No Coords Fountain'
        }
      end
      let(:builder) { described_class.new(record: record_without_coords, api_key: valid_api_key) }

      it 'builds facility with nil coordinates' do
        result = builder.call
        facility = result.data[:facility]

        expect(result).not_to be_success
        expect(facility).to be_nil
      end
    end

    context 'when service does not exist' do
      let(:non_existent_api_key) { 'non-existent-service' }
      let(:builder) { described_class.new(record: valid_record, api_key: non_existent_api_key) }

      before do
        # Stub the API validation to pass
        allow(External::ApiHelper).to receive(:supported_api?).with(non_existent_api_key).and_return(true)
      end

      it 'builds facility without service association' do
        result = builder.call
        facility = result.data[:facility]

        expect(facility.facility_services).to be_blank
      end
    end

    context 'with invalid parameters' do
      let(:builder) { described_class.new(record: nil, api_key: valid_api_key) }

      it 'returns error result without building facility' do
        result = builder.call

        expect(result).to be_failed
        expect(result.data).to be_blank
        expect(result.errors).to include('Record is required')
      end
    end

    context 'when record has invalid data types that cause exceptions' do
      context 'with non-string name field' do
        let(:record_with_invalid_name) do
          {
            'name' => 12345,  # Integer instead of String
            'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
          }
        end
        let(:builder) { described_class.new(record: record_with_invalid_name, api_key: valid_api_key) }

        it 'returns error result with exception message' do
          result = builder.call

          expect(result).to be_failed
          expect(result.data).to be_blank
          expect(result.errors).to include(a_string_matching(/Failed to build facility from record:/))
        end

        it 'logs the error and record data' do
          expect(Rails.logger).to receive(:warn).with(a_string_matching(/Failed to build facility from record:/))
          expect(Rails.logger).to receive(:warn).with("Record data: #{record_with_invalid_name.inspect}")

          builder.call
        end
      end

      context 'with invalid geometry coordinates' do
        let(:record_with_invalid_geometry) do
          {
            'name' => 'Test Fountain',
            'geom' => {
              'geometry' => {
                'coordinates' => 'invalid_string'  # String instead of Array
              }
            }
          }
        end
        let(:builder) { described_class.new(record: record_with_invalid_geometry, api_key: valid_api_key) }

        it 'returns error result with exception message' do
          result = builder.call

          expect(result).to be_failed
          expect(result.data).to be_blank
          expect(result.errors).to include(a_string_matching(/Geometry should be/))
        end
      end

      context 'with invalid geo_point_2d field' do
        let(:record_with_invalid_geo_point) do
          {
            'name' => 'Test Fountain',
            'geo_point_2d' => 'invalid_string'  # String instead of Hash
          }
        end
        let(:builder) { described_class.new(record: record_with_invalid_geo_point, api_key: valid_api_key) }

        it 'returns error result with exception message' do
          result = builder.call

          expect(result).to be_failed
          expect(result.data).to be_blank
          expect(result.errors).to include(a_string_matching(/Geometry should be/))
        end
      end
    end

    context 'when built facility is invalid' do
      let(:invalid_record) do
        {
          'name' => '', # Empty name might make facility invalid
          'geo_point_2d' => { 'lat' => 49.2827, 'lon' => -123.1207 }
        }
      end
      let(:builder) { described_class.new(record: invalid_record, api_key: valid_api_key) }

      it 'returns error result with validation messages' do
        result = builder.call

        expect(result).to be_failed
        expect(result.data).to be_blank
        expect(result.errors.first).to match(/Facility .* is invalid:/)
      end
    end
  end

  describe '.call class method' do
    let(:service) { create(:service, key: valid_api_key) }

    before do
      service # Ensure service exists
    end

    it 'works as a class method' do
      result = described_class.call(record: valid_record, api_key: valid_api_key)
      
      expect(result).to be_success
      expect(result.data[:facility]).to be_a(Facility)
    end
  end
end
