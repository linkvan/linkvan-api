# frozen_string_literal: true

# rubocop:disable RSpec/SpecFilePathFormat

require "rails_helper"

RSpec.describe External::VancouverCity::FacilitySyncer, "#call", type: :service do
  subject(:syncer) { described_class.new(operation:, record:, current: nil, api_key: api_key) }

  let(:operation) { External::SyncOperations.create }
  let(:api_key) { "drinking-fountains" }
  let(:service) { create(:water_fountain_service) }
  let(:valid_record) do
    {
      "mapid" => "CREATE123",
      "name" => "New Valid Fountain",
      "location" => "Valid Park",
      "geo_local_area" => "Downtown",
      "phone" => "604-123-4567",
      "website" => "https://vancouver.ca",
      "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
    }
  end

  let(:invalid_record) do
    {
      "mapid" => "INVALID123",
      "name" => "", # Empty name causes FacilityBuilder to fail
      "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
    }
  end

  before { service } # Ensure service exists

  describe "create operation (:create)" do
    let(:record) { valid_record }

    context "when built facility is valid" do
      it "saves the facility successfully" do
        expect do
          syncer.call
        end.to change(Facility, :count).by(1)
      end

      it "sets result_facility to built_facility" do
        result = syncer.call

        facility = result.data
        expect(facility).to be_persisted
        expect(facility.name).to eq("New Valid Fountain")
        expect(facility.external_id).to eq("CREATE123")
        expect(facility.verified).to be true
      end

      it "creates facility with all expected attributes" do
        result = syncer.call

        facility = result.data
        expect(facility.name).to eq("New Valid Fountain")
        expect(facility.address).to eq("Valid Park, Downtown")
        expect(facility.phone).to eq("604-123-4567")
        expect(facility.website).to eq("https://vancouver.ca")
        expect(facility.lat).to eq(49.2827)
        expect(facility.long).to eq(-123.1207)
        expect(facility.verified).to be true
        expect(facility.external_id).to eq("CREATE123")
      end

      it "creates facility services" do
        result = syncer.call

        facility = result.data
        expect(facility.facility_services.count).to eq(1)
        expect(facility.services).to include(service)
      end

      it "logs creation message with external_id" do
        allow(Rails.logger).to receive(:info)

        syncer.call

        expect(Rails.logger).to have_received(:info).with("Creating new facility with external_id 'CREATE123'")
      end
    end

    context "when FacilityBuilder fails due to invalid data" do
      let(:record) { invalid_record }

      it "does not save facility" do
        expect do
          syncer.call
        end.not_to change(Facility, :count)
      end

      it "adds validation errors to errors array" do
        result = syncer.call

        expect(result).to be_failed
        expect(result.errors).to include(a_string_matching(/can't be blank/i))
      end

      it "sets result_facility to nil" do
        result = syncer.call

        expect(result.data).to be_nil
      end

      it "returns early with no data" do
        result = syncer.call

        expect(result.data).to be_nil # FacilityBuilder fails before operation is determined
        expect(result).to be_failed
      end
    end

    context "when creating database record on success" do
      let(:record) { valid_record }

      it "creates facility with all related records atomically" do
        expect { syncer.call }.to change(Facility, :count).by(1)
          .and change(FacilityService, :count).by(1)
          .and change(FacilitySchedule, :count).by(7) # 7 days of the week
          .and change(FacilityWelcome, :count).by_at_least(1)
      end

      it "creates facility with correct attributes and relationships" do
        result = syncer.call

        facility = result.data
        expect(facility).to be_persisted
        expect(facility.external_id).to eq(record["mapid"])
        expect(facility.name).to eq(record["name"])
        expect(facility.verified).to be true

        # Verify related records are created
        expect(facility.facility_services.count).to eq(1)
        expect(facility.facility_services.first.service).to eq(service)
        expect(facility.schedules.count).to eq(7)
        expect(facility.facility_welcomes.count).to be > 0
      end

      it "ensures all database records are properly linked" do
        result = syncer.call

        facility = result.data

        expect(facility.facility_services.all? { |fs| fs.facility_id == facility.id }).to be true
        expect(facility.schedules.all? { |s| s.facility_id == facility.id }).to be true
        expect(facility.facility_welcomes.all? { |fw| fw.facility_id == facility.id }).to be true
      end
    end

    context "with facility with special characters in name" do
      let(:record) do
        {
          "mapid" => "SPECIAL123",
          "name" => "O'Brien's Water Fountain & Rest Area",
          "location" => "Québec Street",
          "geo_local_area" => "Mount Pleasant",
          "geo_point_2d" => { "lat" => 49.2627, "lon" => -123.1007 }
        }
      end

      it "handles special characters correctly" do
        result = syncer.call

        expect(result).to be_success
        facility = result.data
        expect(facility.name).to eq("O'Brien's Water Fountain & Rest Area")
        expect(facility.address).to eq("Québec Street, Mount Pleasant")
      end
    end

    context "with facility at edge coordinates" do
      let(:record) do
        {
          "mapid" => "EDGE123",
          "name" => "Edge Case Fountain",
          "location" => "Boundary Road",
          "geo_local_area" => "Boundary",
          "geo_point_2d" => { "lat" => 90.0, "lon" => -180.0 }
        }
      end

      it "handles edge coordinate values" do
        result = syncer.call

        expect(result).to be_success
        facility = result.data
        expect(facility.lat).to eq(90.0)
        expect(facility.long).to eq(-180.0)
      end
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
