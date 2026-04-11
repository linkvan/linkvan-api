# frozen_string_literal: true

# rubocop:disable RSpec/SpecFilePathFormat

require "rails_helper"

RSpec.describe External::VancouverCity::FacilitySyncer, "#call - undelete scenarios", type: :service do
  let(:api_key) { "drinking-fountains" }
  let(:service) { create(:water_fountain_service) }

  before { service }

  describe "undelete support" do
    context "when discarded facility has matching external_id" do
      let!(:discarded_facility) do
        create(:facility,
               :with_verified,
               :discarded,
               external_id: "DISCARDED123",
               name: "Discarded Fountain",
               discard_reason: :sync_removed)
      end

      let(:update_record) do
        {
          "mapid" => "DISCARDED123",
          "name" => "Updated Discarded Fountain",
          "location" => "Updated Park",
          "geo_local_area" => "Downtown",
          "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
        }
      end

      it "undeletes the facility before updating" do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        expect(result.data.facility.id).to eq(discarded_facility.id)
        expect(result.data.facility).not_to be_discarded
        expect(result.data.operation).to eq(:external_update)
      end

      it "restores facility to active state" do
        expect do
          syncer = described_class.new(record: update_record, api_key: api_key)
          syncer.call
        end.to change { discarded_facility.reload.undiscarded? }.from(false).to(true)
      end

      it "updates the facility attributes" do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility.reload
        expect(facility.name).to eq("Updated Discarded Fountain")
        expect(facility.address).to eq("Updated Park, Downtown")
        expect(facility.lat).to eq(49.2827)
        expect(facility.long).to eq(-123.1207)
      end

      it "clears the discard_reason" do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility.reload
        expect(facility.discard_reason).to be_nil
      end
    end

    context "when discarded facility has matching name (internal update)" do
      let!(:discarded_internal_facility) do
        create(:facility,
               :discarded,
               external_id: nil,
               name: "Internal Discarded Fountain",
               verified: false,
               discard_reason: :sync_removed)
      end

      let(:name_match_record) do
        {
          "mapid" => "NEW789",
          "name" => "Internal Discarded Fountain",
          "location" => "New Park",
          "geo_local_area" => "East Vancouver",
          "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
        }
      end

      it "undeletes the facility before adding services" do
        syncer = described_class.new(record: name_match_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        expect(result.data.facility.id).to eq(discarded_internal_facility.id)
        expect(result.data.facility).not_to be_discarded
        expect(result.data.operation).to eq(:internal_update)
      end

      it "adds new services to the undeleted facility" do
        original_service_count = discarded_internal_facility.facility_services.count

        syncer = described_class.new(record: name_match_record, api_key: api_key)
        result = syncer.call

        facility = result.data.facility.reload
        expect(facility.facility_services.count).to eq(original_service_count + 1)
        expect(facility.services).to include(service)
      end

      it "restores facility to active state" do
        expect do
          syncer = described_class.new(record: name_match_record, api_key: api_key)
          syncer.call
        end.to change { discarded_internal_facility.reload.undiscarded? }.from(false).to(true)
      end
    end

    context "when multiple discarded facilities exist" do
      let!(:first_discarded) do
        create(:facility,
               :with_verified,
               :discarded,
               external_id: "FIRST123",
               name: "First Discarded",
               discard_reason: :sync_removed)
      end

      let!(:second_discarded) do
        create(:facility,
               :with_verified,
               :discarded,
               external_id: "SECOND456",
               name: "Second Discarded",
               discard_reason: :closed)
      end

      let(:first_record) do
        {
          "mapid" => "FIRST123",
          "name" => "First Updated",
          "location" => "First Park",
          "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
        }
      end

      let(:second_record) do
        {
          "mapid" => "SECOND456",
          "name" => "Second Updated",
          "location" => "Second Park",
          "geo_point_2d" => { "lat" => 49.2828, "lon" => -123.1208 }
        }
      end

      it "undeletes both facilities independently" do
        # First sync
        syncer1 = described_class.new(record: first_record, api_key: api_key)
        result1 = syncer1.call

        expect(result1).to be_success
        expect(result1.data.facility.id).to eq(first_discarded.id)
        expect(result1.data.facility).not_to be_discarded

        # Second sync
        syncer2 = described_class.new(record: second_record, api_key: api_key)
        result2 = syncer2.call

        expect(result2).to be_success
        expect(result2.data.facility.id).to eq(second_discarded.id)
        expect(result2.data.facility).not_to be_discarded
      end
    end

    context "when discarded facility matches by external_id but name differs" do
      let!(:discarded_facility) do
        create(:facility,
               :with_verified,
               :discarded,
               external_id: "EXTERNAL789",
               name: "Old Name",
               discard_reason: :sync_removed)
      end

      let(:renamed_record) do
        {
          "mapid" => "EXTERNAL789",
          "name" => "Completely New Name",
          "location" => "New Park",
          "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
        }
      end

      it "undeletes and updates based on external_id match" do
        syncer = described_class.new(record: renamed_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        expect(result.data.facility.id).to eq(discarded_facility.id)
        expect(result.data.operation).to eq(:external_update)
        expect(result.data.facility.name).to eq("Completely New Name")
      end
    end

    context "interaction with kept facilities" do
      let!(:kept_facility) do
        create(:facility,
               :with_verified,
               external_id: "KEPT123",
               name: "Kept Fountain",
               verified: true)
      end

      let(:update_record) do
        {
          "mapid" => "KEPT123",
          "name" => "Updated Kept Fountain",
          "location" => "Park",
          "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
        }
      end

      it "updates kept facilities without undelete" do
        syncer = described_class.new(record: update_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        expect(result.data.facility.id).to eq(kept_facility.id)
        expect(result.data.operation).to eq(:external_update)
      end

      it "does not change discard state of kept facilities" do
        expect do
          syncer = described_class.new(record: update_record, api_key: api_key)
          syncer.call
        end.not_to(change { kept_facility.reload.discarded? })
      end
    end

    context "name match with discarded internal facility" do
      let!(:discarded_internal) do
        create(:facility,
               :discarded,
               external_id: nil,
               name: "Match By Name",
               verified: false,
               discard_reason: :sync_removed)
      end

      let(:name_record) do
        {
          "mapid" => "NEWID123",
          "name" => "Match By Name",
          "location" => "Park",
          "geo_point_2d" => { "lat" => 49.2827, "lon" => -123.1207 }
        }
      end

      it "undeletes and performs internal update" do
        syncer = described_class.new(record: name_record, api_key: api_key)
        result = syncer.call

        expect(result).to be_success
        expect(result.data.facility.id).to eq(discarded_internal.id)
        expect(result.data.operation).to eq(:internal_update)
        expect(result.data.facility).not_to be_discarded
      end
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
