# frozen_string_literal: true

# rubocop:disable RSpec/SpecFilePathFormat

require "rails_helper"

RSpec.describe External::VancouverCity::FacilitySyncer, "#call", type: :service do
  let(:api_key) { "drinking-fountains" }
  let(:service) { create(:water_fountain_service) }

  before { service }

  describe "transaction rollback scenarios" do
    let!(:existing_facility) do
      create(:facility,
             external_id: "FAIL_UPDATE123",
             name: "Test Facility",
             address: "Test Address")
    end

    context "when ActiveRecord::RecordInvalid occurs during external_update" do
      let(:update_record) do
        {
          "mapid" => "FAIL_UPDATE123",
          "name" => "Updated Name",
          "location" => "Updated Location",
          "geo_local_area" => "Updated Area",
          "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
        }
      end

      before do
        # Stub update! to raise RecordInvalid to simulate validation failure
        relation_stub = instance_double(ActiveRecord::Relation)
        allow(relation_stub).to receive(:find_by).with(external_id: "FAIL_UPDATE123").and_return(existing_facility)
        allow(Facility).to receive(:with_discarded).and_return(relation_stub)
        allow(existing_facility).to receive(:update!).and_raise(
          ActiveRecord::RecordInvalid.new(existing_facility)
        )
      end

      it "rolls back transaction and reports error" do
        original_name = existing_facility.name
        syncer = described_class.new(record: update_record, api_key: api_key, current: existing_facility)
        result = syncer.call

        existing_facility.reload
        expect(existing_facility.name).to eq(original_name) # No change due to rollback
        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Failed to save facility/))
        expect(result.data.operation).to eq(:external_update)
        expect(result.data.facility).to be_nil
      end
    end

    context "when StandardError occurs during service synchronization" do
      let!(:existing_facility) do
        create(:facility,
               external_id: "SERVICE_ERROR123",
               name: "Test Facility")
      end

      let(:update_record) do
        {
          "mapid" => "SERVICE_ERROR123",
          "name" => "Updated Name",
          "location" => "Updated Location",
          "geo_local_area" => "Updated Area",
          "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
        }
      end

      before do
        # Stub facility_services.create! to raise StandardError
        relation_stub = instance_double(ActiveRecord::Relation)
        allow(relation_stub).to receive(:find_by).with(external_id: "SERVICE_ERROR123").and_return(existing_facility)
        allow(Facility).to receive(:with_discarded).and_return(relation_stub)
        allow(existing_facility.facility_services).to receive(:create!).and_raise(StandardError.new("Database connection lost"))
      end

      it "rolls back transaction and reports error" do
        original_service_count = existing_facility.facility_services.count
        syncer = described_class.new(record: update_record, api_key: api_key, current: existing_facility)
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

  describe "error message formatting" do
    context "when FacilityBuilder fails due to validation errors" do
      let(:invalid_facility_record) do
        {
          "mapid" => "INVALID123",
          "name" => "", # Invalid name causes FacilityBuilder to fail
          "location" => "Test Location",
          "geo_local_area" => "Downtown",
          "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
        }
      end

      it "includes detailed validation errors from FacilityBuilder" do
        syncer = described_class.new(record: invalid_facility_record, api_key: api_key, current: nil)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors.first).to match(/Name can't be blank/)
        expect(result.data.operation).to be_nil # No operation determined when FacilityBuilder fails
        expect(result.data.facility).to be_nil
      end
    end

    context "when ActiveRecord::RecordInvalid provides detailed message" do
      let(:valid_record) do
        {
          "mapid" => "VALID_RECORD",
          "name" => "Valid Facility",
          "location" => "Test Location",
          "geo_local_area" => "Downtown",
          "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
        }
      end

      it "includes the detailed ActiveRecord error message" do
        # Create a facility with the same external_id to trigger a unique constraint violation on save
        create(:facility, external_id: "VALID_RECORD")

        syncer = described_class.new(record: valid_record, api_key: api_key, current: nil)
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/Failed to save facility/))
      end
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
