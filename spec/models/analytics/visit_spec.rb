# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Visit, type: :model do
  # Use the factory for clean test setup
  subject(:visit) { build(:analytics_visit) }

  describe "Factory" do
    it "creates a valid visit with default factory" do
      expect(create(:analytics_visit)).to be_valid
    end

    context "with traits" do
      it "creates a valid visit with coordinates" do
        visit = create(:analytics_visit, :with_coordinates)
        expect(visit).to be_valid
        expect(visit.lat).to be_present
        expect(visit.long).to be_present
      end

      it "creates a valid visit with vancouver_center trait" do
        visit = create(:analytics_visit, :vancouver_center)
        expect(visit).to be_valid
        expect(visit.lat).to eq(49.2827)
        expect(visit.long).to eq(-123.1207)
      end

      it "creates a valid visit with downtown_vancouver trait" do
        visit = create(:analytics_visit, :downtown_vancouver)
        expect(visit).to be_valid
        expect(visit.lat).to eq(49.2848)
        expect(visit.long).to eq(-123.1228)
      end

      it "creates a valid visit with outside_vancouver trait" do
        visit = create(:analytics_visit, :outside_vancouver)
        expect(visit).to be_valid
        expect(visit.lat).to be_present
        expect(visit.long).to be_present
      end

      it "creates a valid visit with invalid_coordinates trait" do
        visit = create(:analytics_visit, :invalid_coordinates)
        expect(visit).to be_valid
        expect(visit.lat).to eq(-33.8688)
        expect(visit.long).to eq(151.2093)
      end

      it "creates a valid visit with new_session trait" do
        visit = create(:analytics_visit, :new_session)
        expect(visit).to be_valid
        expect(visit.created_at).to be_within(1.minute).of(1.hour.ago)
      end

      it "creates a valid visit with returning_session trait" do
        visit = create(:analytics_visit, :returning_session)
        expect(visit).to be_valid
        expect(visit.created_at).to be_within(1.minute).of(1.day.ago)
        expect(visit.updated_at).to be_within(1.minute).of(10.minutes.ago)
      end

      it "creates a valid visit with mobile_session trait" do
        visit = create(:analytics_visit, :mobile_session)
        expect(visit).to be_valid
        expect(visit.lat).to be_present
        expect(visit.long).to be_present
      end

      it "creates a valid visit with desktop_session trait" do
        visit = create(:analytics_visit, :desktop_session)
        expect(visit).to be_valid
        expect(visit.lat).to be_nil
        expect(visit.long).to be_nil
      end
    end
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_presence_of(:session_id) }

    it "validates uniqueness of session_id scoped to uuid" do
      create(:analytics_visit, uuid: "test-uuid-123", session_id: "test-session-123")
      new_visit = build(:analytics_visit, uuid: "test-uuid-123", session_id: "test-session-123")

      expect(new_visit).not_to be_valid
      expect(new_visit.errors[:session_id]).to include("has already been taken")
    end

    it "allows same session_id with different uuid" do
      create(:analytics_visit, uuid: "uuid-1", session_id: "same-session")
      new_visit = build(:analytics_visit, uuid: "uuid-2", session_id: "same-session")

      expect(new_visit).to be_valid
    end

    it "allows same uuid with different session_id" do
      create(:analytics_visit, uuid: "same-uuid", session_id: "session-1")
      new_visit = build(:analytics_visit, uuid: "same-uuid", session_id: "session-2")

      expect(new_visit).to be_valid
    end

    context "with coordinates" do
      it "allows nil coordinates" do
        visit = build(:analytics_visit, lat: nil, long: nil)
        expect(visit).to be_valid
      end

      it "allows valid latitude" do
        visit = build(:analytics_visit, lat: 49.2827, long: -123.1207)
        expect(visit).to be_valid
      end

      it "allows negative latitude" do
        visit = build(:analytics_visit, lat: -33.8688, long: 151.2093)
        expect(visit).to be_valid
      end

      it "allows positive longitude" do
        visit = build(:analytics_visit, lat: 49.2827, long: 151.2093)
        expect(visit).to be_valid
      end
    end
  end

  describe "Associations" do
    it { is_expected.to have_many(:events).dependent(:destroy) }
    it { is_expected.to have_many(:impressions).through(:events) }

    context "with dependent destroy" do
      it "destroys associated events when visit is destroyed" do
        visit = create(:analytics_visit)
        event1 = create(:analytics_event, visit: visit)
        event2 = create(:analytics_event, visit: visit)

        expect { visit.destroy }.to change(Analytics::Event, :count).by(-2)
        expect(Analytics::Event.find_by(id: event1.id)).to be_nil
        expect(Analytics::Event.find_by(id: event2.id)).to be_nil
      end
    end

    context "through associations" do
      let(:visit) { create(:analytics_visit) }
      let(:event) { create(:analytics_event, visit: visit) }
      let!(:impression1) { create(:analytics_impression, event: event) }
      let!(:impression2) { create(:analytics_impression, event: event) }

      it "can access impressions through events" do
        expect(visit.impressions).to contain_exactly(impression1, impression2)
      end
    end
  end

  describe "#attempt_update_coordinates" do
    context "when coordinates are already set" do
      let(:visit) { create(:analytics_visit, :vancouver_center) }

      it "does not update coordinates" do
        original_lat = visit.lat
        original_long = visit.long
        params = { lat: 50.0, long: -124.0 }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        expect(visit.lat).to eq(original_lat)
        expect(visit.long).to eq(original_long)
      end

      it "updates when one coordinate is blank" do
        visit.update!(lat: 49.2827, long: nil)
        params = { lat: 50.0, long: -124.0 }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        # Updates both because the condition checks if ANY coordinate is blank
        expect(visit.lat).to eq(50.0)
        expect(visit.long).to eq(-124.0)
      end
    end

    context "when coordinates are not set" do
      let(:visit) { create(:analytics_visit, lat: nil, long: nil) }

      it "updates coordinates with valid params" do
        params = { lat: 49.2827, long: -123.1207 }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        expect(visit.lat).to eq(49.2827)
        expect(visit.long).to eq(-123.1207)
      end

      it "updates coordinates with only lat provided" do
        params = { lat: 49.2827 }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        expect(visit.lat).to eq(49.2827)
        expect(visit.long).to be_nil
      end

      it "updates coordinates with only long provided" do
        params = { long: -123.1207 }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        expect(visit.lat).to be_nil
        expect(visit.long).to eq(-123.1207)
      end

      it "handles string keys in params" do
        params = { "lat" => "49.2827", "long" => "-123.1207" }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        # Rails converts strings to BigDecimal for numeric columns
        expect(visit.lat).to be_a(BigDecimal)
        expect(visit.long).to be_a(BigDecimal)
        expect(visit.lat.to_f).to eq(49.2827)
        expect(visit.long.to_f).to eq(-123.1207)
      end

      it "handles nil params" do
        result = visit.attempt_update_coordinates(nil)

        expect(result).to eq(visit)
        expect(visit.lat).to be_nil
        expect(visit.long).to be_nil
      end

      it "handles empty hash params" do
        result = visit.attempt_update_coordinates({})

        expect(result).to eq(visit)
        expect(visit.lat).to be_nil
        expect(visit.long).to be_nil
      end

      it "ignores non-coordinate params" do
        params = { lat: 49.2827, long: -123.1207, other_param: "value" }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        expect(visit.lat).to eq(49.2827)
        expect(visit.long).to eq(-123.1207)
      end
    end

    context "when only one coordinate is blank" do
      let(:visit) { create(:analytics_visit, lat: 49.2827, long: nil) }

      it "updates both coordinates when one is blank" do
        params = { lat: 50.0, long: -124.0 }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        # Updates both because the condition checks if ANY coordinate is blank
        expect(visit.lat).to eq(50.0)
        expect(visit.long).to eq(-124.0)
      end
    end

    context "edge cases" do
      let(:visit) { create(:analytics_visit, lat: nil, long: nil) }

      it "handles negative coordinates" do
        params = { lat: -33.8688, long: 151.2093 }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        expect(visit.lat).to eq(-33.8688)
        expect(visit.long).to eq(151.2093)
      end

      it "handles zero coordinates" do
        params = { lat: 0, long: 0 }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        expect(visit.lat).to eq(0)
        expect(visit.long).to eq(0)
      end

      it "handles very small coordinates" do
        params = { lat: 0.000001, long: -0.000001 }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        expect(visit.lat).to eq(0.000001)
        expect(visit.long).to eq(-0.000001)
      end

      it "handles very large coordinates" do
        params = { lat: 90, long: 180 }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        expect(visit.lat).to eq(90)
        expect(visit.long).to eq(180)
      end

      it "handles symbol keys" do
        params = { lat: 49.2827, long: -123.1207 }

        result = visit.attempt_update_coordinates(params)

        expect(result).to eq(visit)
        expect(visit.lat).to eq(49.2827)
        expect(visit.long).to eq(-123.1207)
      end
    end
  end

  describe "private methods" do
    describe "#extract_coordinates_from" do
      let(:visit) { create(:analytics_visit) }

      it "extracts lat and long from params" do
        params = { lat: 49.2827, long: -123.1207, other: "value" }

        # Use send to call private method for testing
        result = visit.send(:extract_coordinates_from, params)

        expect(result).to eq({ "lat" => 49.2827, "long" => -123.1207 })
      end

      it "handles nil params" do
        result = visit.send(:extract_coordinates_from, nil)

        expect(result).to eq({})
      end

      it "handles params with only lat" do
        params = { lat: 49.2827, other: "value" }

        result = visit.send(:extract_coordinates_from, params)

        expect(result).to eq({ "lat" => 49.2827 })
      end

      it "handles params with only long" do
        params = { long: -123.1207, other: "value" }

        result = visit.send(:extract_coordinates_from, params)

        expect(result).to eq({ "long" => -123.1207 })
      end

      it "handles string keys" do
        params = { "lat" => 49.2827, "long" => -123.1207 }

        result = visit.send(:extract_coordinates_from, params)

        expect(result).to eq({ "lat" => 49.2827, "long" => -123.1207 })
      end

      it "handles empty params" do
        result = visit.send(:extract_coordinates_from, {})

        expect(result).to eq({})
      end
    end
  end

  describe "scopes and class methods" do
    context "when searching by uuid" do
      let!(:visit1) { create(:analytics_visit, uuid: "test-uuid-1") }
      let!(:visit2) { create(:analytics_visit, uuid: "test-uuid-2") }

      it "can find visits by uuid" do
        expect(described_class.find_by(uuid: "test-uuid-1")).to eq(visit1)
      end
    end

    context "when searching by session_id" do
      let!(:visit1) { create(:analytics_visit, session_id: "session-1") }
      let!(:visit2) { create(:analytics_visit, session_id: "session-2") }

      it "can find visits by session_id" do
        expect(described_class.find_by(session_id: "session-1")).to eq(visit1)
      end
    end
  end

  describe "timestamp behavior" do
    it "sets created_at and updated_at on creation" do
      visit = create(:analytics_visit)

      expect(visit.created_at).to be_present
      expect(visit.updated_at).to be_present
      expect(visit.created_at).to be_within(1.second).of(visit.updated_at)
    end

    it "updates updated_at on coordinate update" do
      visit = create(:analytics_visit, lat: nil, long: nil)
      original_updated_at = visit.updated_at

      travel_to(1.minute.from_now) do
        visit.attempt_update_coordinates({ lat: 49.2827, long: -123.1207 })
        visit.reload

        expect(visit.updated_at).to be > original_updated_at
      end
    end

    it "does not update updated_at when coordinates are not updated" do
      visit = create(:analytics_visit, :vancouver_center)
      original_updated_at = visit.updated_at

      travel_to(1.minute.from_now) do
        visit.attempt_update_coordinates({ lat: 50.0, long: -124.0 })
        visit.reload

        expect(visit.updated_at).to eq(original_updated_at)
      end
    end
  end
end
