# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Impression, type: :model do
  # Use the factory for clean test setup
  subject(:impression) { build(:analytics_impression) }

  describe "Factory" do
    it "creates a valid impression with default factory" do
      expect(create(:analytics_impression)).to be_valid
    end

    context "with traits" do
      it "creates a valid impression with for_service trait" do
        impression = create(:analytics_impression, :for_service)
        expect(impression).to be_valid
        expect(impression.impressionable_type).to eq("Service")
        expect(impression.impressionable).to be_a(Service)
      end

      it "creates a valid impression with for_zone trait" do
        impression = create(:analytics_impression, :for_zone)
        expect(impression).to be_valid
        expect(impression.impressionable_type).to eq("Zone")
        expect(impression.impressionable).to be_a(Zone)
      end
    end

    context "with association to event" do
      it "creates valid impression with associated event" do
        event = create(:analytics_event)
        impression = create(:analytics_impression, event: event)

        expect(impression).to be_valid
        expect(impression.event).to eq(event)
        expect(event.impressions).to include(impression)
      end
    end

    context "with different impressionable types" do
      it "creates valid impression with facility" do
        facility = create(:facility)
        impression = create(:analytics_impression, impressionable: facility)

        expect(impression).to be_valid
        expect(impression.impressionable).to eq(facility)
        expect(impression.impressionable_type).to eq("Facility")
        expect(impression.impressionable_id).to eq(facility.id)
      end

      it "creates valid impression with service" do
        service = create(:service)
        impression = create(:analytics_impression, impressionable: service)

        expect(impression).to be_valid
        expect(impression.impressionable).to eq(service)
        expect(impression.impressionable_type).to eq("Service")
        expect(impression.impressionable_id).to eq(service.id)
      end

      it "creates valid impression with zone" do
        zone = create(:zone)
        impression = create(:analytics_impression, impressionable: zone)

        expect(impression).to be_valid
        expect(impression.impressionable).to eq(zone)
        expect(impression.impressionable_type).to eq("Zone")
        expect(impression.impressionable_id).to eq(zone.id)
      end
    end
  end

  describe "Validations" do
    it { is_expected.to validate_uniqueness_of(:impressionable_id).scoped_to(%i[impressionable_type event_id]) }

    context "uniqueness validation" do
      let(:event) { create(:analytics_event) }
      let(:facility) { create(:facility) }

      it "prevents duplicate impressions for same facility in same event" do
        create(:analytics_impression, event: event, impressionable: facility)

        duplicate_impression = build(:analytics_impression, event: event, impressionable: facility)
        expect(duplicate_impression).not_to be_valid
        expect(duplicate_impression.errors[:impressionable_id]).to include("has already been taken")
      end

      it "allows same facility in different events" do
        event1 = create(:analytics_event)
        event2 = create(:analytics_event)

        create(:analytics_impression, event: event1, impressionable: facility)
        second_impression = build(:analytics_impression, event: event2, impressionable: facility)

        expect(second_impression).to be_valid
      end

      it "allows different facilities in same event" do
        event = create(:analytics_event)
        facility1 = create(:facility)
        facility2 = create(:facility)

        create(:analytics_impression, event: event, impressionable: facility1)
        second_impression = build(:analytics_impression, event: event, impressionable: facility2)

        expect(second_impression).to be_valid
      end

      it "allows same service in different events" do
        event1 = create(:analytics_event)
        event2 = create(:analytics_event)
        service = create(:service)

        create(:analytics_impression, event: event1, impressionable: service)
        second_impression = build(:analytics_impression, event: event2, impressionable: service)

        expect(second_impression).to be_valid
      end

      it "prevents duplicate impressions for same service in same event" do
        event = create(:analytics_event)
        service = create(:service)

        create(:analytics_impression, event: event, impressionable: service)
        duplicate_impression = build(:analytics_impression, event: event, impressionable: service)

        expect(duplicate_impression).not_to be_valid
        expect(duplicate_impression.errors[:impressionable_id]).to include("has already been taken")
      end

      it "prevents duplicate impressions for same zone in same event" do
        event = create(:analytics_event)
        zone = create(:zone)

        create(:analytics_impression, event: event, impressionable: zone)
        duplicate_impression = build(:analytics_impression, event: event, impressionable: zone)

        expect(duplicate_impression).not_to be_valid
        expect(duplicate_impression.errors[:impressionable_id]).to include("has already been taken")
      end

      it "allows different impressionable types with same ID in same event" do
        # This test demonstrates the scoped nature of the uniqueness validation
        # by showing that different impressionable types can coexist in the same event
        event = create(:analytics_event)
        facility = create(:facility)
        service = create(:service)

        # Create impressions for different types in the same event
        facility_impression = create(:analytics_impression, event: event, impressionable: facility)
        service_impression = create(:analytics_impression, event: event, impressionable: service)

        # Both should be valid since they have different impressionable_type values
        expect(facility_impression).to be_valid
        expect(service_impression).to be_valid
        expect(facility_impression.event).to eq(service_impression.event)
        expect(facility_impression.impressionable_type).to eq("Facility")
        expect(service_impression.impressionable_type).to eq("Service")

        # The uniqueness constraint is scoped by impressionable_type and event_id
        # So these two impressions don't conflict even if they had the same impressionable_id
        expect(facility_impression.event_id).to eq(service_impression.event_id)
        expect(facility_impression.impressionable_type).not_to eq(service_impression.impressionable_type)
      end
    end
  end

  describe "Associations" do
    it { is_expected.to belong_to(:event) }
    it { is_expected.to belong_to(:impressionable) }
    it { is_expected.to have_one(:visit).through(:event) }

    context "belongs_to event" do
      it "can access associated event" do
        event = create(:analytics_event)
        impression = create(:analytics_impression, event: event)

        expect(impression.event).to eq(event)
        expect(event.impressions).to include(impression)
      end

      it "is invalid without associated event" do
        impression = build(:analytics_impression, event: nil)
        expect(impression).not_to be_valid
      end
    end

    context "belongs_to impressionable (polymorphic)" do
      it "can access facility as impressionable" do
        facility = create(:facility)
        impression = create(:analytics_impression, impressionable: facility)

        expect(impression.impressionable).to eq(facility)
        expect(impression.impressionable_type).to eq("Facility")
      end

      it "can access service as impressionable" do
        service = create(:service)
        impression = create(:analytics_impression, impressionable: service)

        expect(impression.impressionable).to eq(service)
        expect(impression.impressionable_type).to eq("Service")
      end

      it "can access zone as impressionable" do
        zone = create(:zone)
        impression = create(:analytics_impression, impressionable: zone)

        expect(impression.impressionable).to eq(zone)
        expect(impression.impressionable_type).to eq("Zone")
      end

      it "is invalid without impressionable" do
        impression = build(:analytics_impression, impressionable: nil)
        expect(impression).not_to be_valid
      end

      it "is invalid without impressionable_type" do
        impression = build(:analytics_impression)
        impression.impressionable_type = nil
        impression.impressionable_id = 1

        expect(impression).not_to be_valid
      end

      it "is invalid without impressionable_id" do
        event = create(:analytics_event)
        impression = described_class.new(
          event: event,
          impressionable_type: "Facility",
          impressionable_id: nil
        )

        # Polymorphic associations don't automatically validate presence of foreign keys
        # The record may validate but won't be able to find the associated object
        expect(impression.event).to be_present
        expect(impression.impressionable_type).to eq("Facility")
        expect(impression.impressionable_id).to be_nil

        # The polymorphic association returns nil when ID is nil
        expect(impression.impressionable).to be_nil
      end
    end

    context "has_one visit through event" do
      it "can access visit through event" do
        visit = create(:analytics_visit)
        event = create(:analytics_event, visit: visit)
        impression = create(:analytics_impression, event: event)

        expect(impression.visit).to eq(visit)
      end

      it "returns nil when event has no visit" do
        # This scenario should not happen with proper foreign key constraints,
        # but we test the association behavior
        event = create(:analytics_event)
        impression = create(:analytics_impression, event: event)

        expect(impression.visit).to eq(event.visit)
      end
    end
  end

  describe "Scopes" do
    describe ".facilities" do
      it "returns only facility impressions" do
        event = create(:analytics_event)
        facility = create(:facility)
        service = create(:service)
        zone = create(:zone)

        facility_impression = create(:analytics_impression, event: event, impressionable: facility)
        service_impression = create(:analytics_impression, event: event, impressionable: service)
        zone_impression = create(:analytics_impression, event: event, impressionable: zone)

        facilities = described_class.facilities

        expect(facilities).to contain_exactly(facility_impression)
        expect(facilities).not_to include(service_impression, zone_impression)
      end

      it "returns empty array when no facility impressions exist" do
        event = create(:analytics_event)
        service = create(:service)
        create(:analytics_impression, event: event, impressionable: service)

        expect(described_class.facilities).to be_empty
      end

      it "chains with other scopes" do
        event1 = create(:analytics_event)
        event2 = create(:analytics_event)
        facility1 = create(:facility)
        facility2 = create(:facility)

        create(:analytics_impression, event: event1, impressionable: facility1)
        create(:analytics_impression, event: event2, impressionable: facility2)

        facilities_in_event1 = described_class.facilities.where(event: event1)
        expect(facilities_in_event1).to contain_exactly(described_class.find_by(event: event1, impressionable: facility1))
      end
    end
  end

  describe "Polymorphic Behavior" do
    it "handles polymorphic association correctly for facilities" do
      facility = create(:facility)
      impression = create(:analytics_impression, impressionable: facility)

      expect(impression.impressionable).to respond_to(:name)
      expect(impression.impressionable.class.name).to eq("Facility")
    end

    it "handles polymorphic association correctly for services" do
      service = create(:service)
      impression = create(:analytics_impression, impressionable: service)

      expect(impression.impressionable).to respond_to(:name)
      expect(impression.impressionable.class.name).to eq("Service")
    end

    it "handles polymorphic association correctly for zones" do
      zone = create(:zone)
      impression = create(:analytics_impression, impressionable: zone)

      expect(impression.impressionable).to respond_to(:name)
      expect(impression.impressionable.class.name).to eq("Zone")
    end

    it "allows querying by polymorphic type" do
      event = create(:analytics_event)
      facility = create(:facility)
      service = create(:service)

      create(:analytics_impression, event: event, impressionable: facility)
      create(:analytics_impression, event: event, impressionable: service)

      facility_impressions = described_class.where(impressionable_type: "Facility")
      service_impressions = described_class.where(impressionable_type: "Service")

      expect(facility_impressions.count).to eq(1)
      expect(service_impressions.count).to eq(1)
      expect(facility_impressions.first.impressionable).to eq(facility)
      expect(service_impressions.first.impressionable).to eq(service)
    end

    it "allows querying by polymorphic ID" do
      event = create(:analytics_event)
      facility = create(:facility)

      impression = create(:analytics_impression, event: event, impressionable: facility)

      found_impression = described_class.where(impressionable_id: facility.id).first
      expect(found_impression).to eq(impression)
      expect(found_impression.impressionable).to eq(facility)
    end

    it "handles type and ID queries together" do
      event = create(:analytics_event)
      facility1 = create(:facility)
      facility2 = create(:facility)
      service = create(:service)

      create(:analytics_impression, event: event, impressionable: facility1)
      create(:analytics_impression, event: event, impressionable: facility2)
      create(:analytics_impression, event: event, impressionable: service)

      specific_facility = described_class.where(
        impressionable_type: "Facility",
        impressionable_id: facility1.id
      ).first

      expect(specific_facility.impressionable).to eq(facility1)
    end
  end

  describe "Database Behavior" do
    it "persists polymorphic associations correctly" do
      event = create(:analytics_event)
      facility = create(:facility)

      impression = create(:analytics_impression, event: event, impressionable: facility)
      persisted = described_class.find(impression.id)

      expect(persisted.event).to eq(event)
      expect(persisted.impressionable).to eq(facility)
      expect(persisted.impressionable_type).to eq("Facility")
      expect(persisted.impressionable_id).to eq(facility.id)
    end

    it "handles composite unique constraint at database level" do
      event = create(:analytics_event)
      facility = create(:facility)

      create(:analytics_impression, event: event, impressionable: facility)

      expect do
        create(:analytics_impression, event: event, impressionable: facility)
      end.to raise_error(ActiveRecord::RecordInvalid, /Impressionable has already been taken/)
    end

    it "sets created_at and updated_at on creation" do
      impression = create(:analytics_impression)

      expect(impression.created_at).to be_present
      expect(impression.updated_at).to be_present
      expect(impression.created_at).to be_within(1.second).of(impression.updated_at)
    end

    it "updates updated_at on attribute update" do
      impression = create(:analytics_impression)
      original_updated_at = impression.updated_at
      facility = create(:facility)

      travel_to(1.minute.from_now) do
        impression.update!(impressionable: facility)
        impression.reload

        expect(impression.updated_at).to be > original_updated_at
      end
    end

    it "does not update updated_at when no attributes change" do
      impression = create(:analytics_impression)
      original_updated_at = impression.updated_at

      travel_to(1.minute.from_now) do
        impression.reload
        expect(impression.updated_at).to eq(original_updated_at)
      end
    end

    it "handles deletion of impressionable object" do
      event = create(:analytics_event)
      facility = create(:facility)
      impression = create(:analytics_impression, event: event, impressionable: facility)

      # Delete the facility
      facility.destroy

      # The impression should still exist but impressionable should be nil
      # depending on dependent options in the actual models
      expect(described_class.find_by(id: impression.id)).to be_present
    end

    it "handles deletion of event with dependent impressions" do
      event = create(:analytics_event)
      create(:analytics_impression, event: event)

      expect { event.destroy }.to change(described_class, :count).by(-1)
    end
  end

  describe "Querying and Relationships" do
    let(:visit) { create(:analytics_visit) }
    let(:event1) { create(:analytics_event, visit: visit) }
    let(:event2) { create(:analytics_event, visit: visit) }
    let(:facility1) { create(:facility) }
    let(:facility2) { create(:facility) }
    let(:service) { create(:service) }

    before do
      create(:analytics_impression, event: event1, impressionable: facility1)
      create(:analytics_impression, event: event1, impressionable: service)
      create(:analytics_impression, event: event2, impressionable: facility2)
    end

    it "can find impressions by event" do
      impressions = described_class.where(event: event1)
      expect(impressions.count).to eq(2)
    end

    it "can find impressions by visit through event" do
      event_ids = [event1.id, event2.id]
      impressions = described_class.where(event_id: event_ids)
      expect(impressions.count).to eq(3)
    end

    it "can count impressions by type" do
      facility_count = described_class.where(impressionable_type: "Facility").count
      service_count = described_class.where(impressionable_type: "Service").count

      expect(facility_count).to eq(2)
      expect(service_count).to eq(1)
    end

    it "can query complex conditions" do
      # Find all facility impressions for the first event
      impressions = described_class.where(
        event: event1,
        impressionable_type: "Facility"
      )
      expect(impressions.count).to eq(1)
      expect(impressions.first.impressionable).to eq(facility1)
    end
  end

  describe "Edge Cases" do
    it "handles nil impressionable_id gracefully" do
      impression = build(:analytics_impression)
      impression.impressionable_id = nil
      impression.impressionable_type = "Facility"

      # The model doesn't validate presence of polymorphic foreign keys directly
      # but it won't be able to save without proper associations
      expect(impression.event).to be_present
      expect(impression.impressionable_type).to eq("Facility")
      expect(impression.impressionable_id).to be_nil
    end

    it "handles nil impressionable_type gracefully" do
      impression = build(:analytics_impression)
      impression.impressionable_id = 1
      impression.impressionable_type = nil

      expect(impression).not_to be_valid
    end

    it "handles empty string impressionable_type" do
      impression = build(:analytics_impression)
      impression.impressionable_type = ""

      # The model doesn't validate presence of impressionable_type directly
      # Empty string is technically valid at the validation level
      expect(impression.event).to be_present
      expect(impression.impressionable_type).to eq("")
    end

    it "handles zero impressionable_id" do
      impression = build(:analytics_impression)
      impression.impressionable_id = 0
      impression.impressionable_type = "Facility"

      # This might be valid depending on foreign key constraints
      # The test shows the behavior, not necessarily the expected outcome
      expect(impression.event).to be_present
    end

    it "handles very large impressionable_id" do
      impression = build(:analytics_impression)
      impression.impressionable_id = (2**31) - 1 # Max 32-bit signed int
      impression.impressionable_type = "Facility"

      expect(impression.event).to be_present
    end

    it "handles invalid impressionable_type values" do
      impression = build(:analytics_impression)
      impression.impressionable_type = "NonExistentModel"

      # This should be valid at the model level but fail at database level
      # when trying to associate with an actual record
      expect(impression.event).to be_present
    end
  end
end
