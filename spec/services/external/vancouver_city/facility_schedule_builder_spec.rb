# frozen_string_literal: true

require 'rails_helper'

RSpec.describe External::VancouverCity::FacilityScheduleBuilder, type: :service do
  let(:facility) { build(:facility) }
  let(:fields) { { 'name' => 'Test Facility' } }

  describe '#initialize' do
    it 'initializes with valid parameters' do
      builder = described_class.new(facility: facility, fields: fields)
      
      expect(builder.facility).to eq(facility)
      expect(builder.fields).to eq(fields)
    end
  end

  describe '#validate' do
    context 'with valid parameters' do
      let(:builder) { described_class.new(facility: facility, fields: fields) }

      it 'returns empty errors array' do
        expect(builder.validate).to be_empty
      end

      it 'is valid' do
        expect(builder).to be_valid
      end
    end

    context 'with nil facility' do
      let(:builder) { described_class.new(facility: nil, fields: fields) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Facility is required')
      end

      it 'is invalid' do
        expect(builder).to be_invalid
      end
    end

    context 'with non-facility object' do
      let(:builder) { described_class.new(facility: 'invalid', fields: fields) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Facility must be a Facility object')
      end
    end

    context 'with nil fields' do
      let(:builder) { described_class.new(facility: facility, fields: nil) }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Fields are required')
      end
    end

    context 'with non-hash fields' do
      let(:builder) { described_class.new(facility: facility, fields: 'invalid') }

      it 'returns validation errors' do
        errors = builder.validate
        expect(errors).to include('Fields must be a Hash')
      end
    end
  end

  describe '#call' do
    context 'with valid parameters' do
      let(:builder) { described_class.new(facility: facility, fields: fields) }

      it 'returns successful result' do
        result = builder.call
        
        expect(result).to be_success
        expect(result.errors).to be_empty
        expect(result.data[:schedules_count]).to eq(7)
      end

      it 'creates schedules for all weekdays' do
        builder.call

        expect(facility.schedules.size).to eq(7)
        facility.schedules.each do |schedule|
          expect(schedule.closed_all_day).to be false
          expect(schedule.open_all_day).to be true
        end
      end

      it 'creates exactly one schedule for each day of the week' do
        builder.call

        # Test that each day is covered exactly once
        week_days = facility.schedules.map(&:week_day)
        expect(week_days.sort).to eq(FacilitySchedule.week_days.keys.sort)
      end

      it 'creates valid schedule objects' do
        builder.call

        facility.schedules.each do |schedule|
          expect(schedule).to be_valid, "Expected #{schedule.week_day} schedule to be valid: #{schedule.errors.full_messages}"
        end
      end
    end

    context 'with invalid parameters' do
      let(:builder) { described_class.new(facility: nil, fields: nil) }

      it 'returns error result without building schedules' do
        result = builder.call

        expect(result).to be_failed
        expect(result.data).to be_nil
        expect(result.errors).to include('Facility is required')
        expect(result.errors).to include('Fields are required')
      end
    end
  end

  describe '.call class method' do
    it 'works as a class method' do
      result = described_class.call(facility: facility, fields: fields)
      
      expect(result).to be_success
      expect(result.data[:schedules_count]).to eq(7)
    end
  end
end
