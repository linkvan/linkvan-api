# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Event, type: :model do
  # Use the factory for clean test setup
  subject(:event) { build(:analytics_event) }

  describe "Factory" do
    it "creates a valid event with default factory" do
      expect(create(:analytics_event)).to be_valid
    end

    context "with traits" do
      it "creates a valid event with show_action trait" do
        event = create(:analytics_event, :show_action)
        expect(event).to be_valid
        expect(event.action_name).to eq("show")
        expect(event.request_url).to eq("https://example.com/facilities/1")
      end

      it "creates a valid event with create_action trait" do
        event = create(:analytics_event, :create_action)
        expect(event).to be_valid
        expect(event.action_name).to eq("create")
        expect(event.request_url).to eq("https://example.com/facilities")
      end

      it "creates a valid event with update_action trait" do
        event = create(:analytics_event, :update_action)
        expect(event).to be_valid
        expect(event.action_name).to eq("update")
        expect(event.request_url).to eq("https://example.com/facilities/1")
      end

      it "creates valid events with combined traits" do
        event = create(:analytics_event, :show_action)
        expect(event.controller_name).to eq("facilities")
        expect(event.action_name).to eq("show")
      end
    end

    context "with association to visit" do
      it "creates valid event with associated visit" do
        visit = create(:analytics_visit)
        event = create(:analytics_event, visit: visit)

        expect(event).to be_valid
        expect(event.visit).to eq(visit)
        expect(visit.events).to include(event)
      end
    end
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:controller_name) }
    it { is_expected.to validate_presence_of(:action_name) }
    it { is_expected.to validate_presence_of(:request_url) }

    context "when controller_name is missing" do
      it "is invalid" do
        event = build(:analytics_event, controller_name: nil)
        expect(event).not_to be_valid
        expect(event.errors[:controller_name]).to include("can't be blank")
      end
    end

    context "when action_name is missing" do
      it "is invalid" do
        event = build(:analytics_event, action_name: nil)
        expect(event).not_to be_valid
        expect(event.errors[:action_name]).to include("can't be blank")
      end
    end

    context "when request_url is missing" do
      it "is invalid" do
        event = build(:analytics_event, request_url: nil)
        expect(event).not_to be_valid
        expect(event.errors[:request_url]).to include("can't be blank")
      end
    end

    context "with optional fields" do
      it "allows nil latitude" do
        event = build(:analytics_event, lat: nil)
        expect(event).to be_valid
      end

      it "allows nil longitude" do
        event = build(:analytics_event, long: nil)
        expect(event).to be_valid
      end

      it "allows nil request_ip" do
        event = build(:analytics_event, request_ip: nil)
        expect(event).to be_valid
      end

      it "allows nil request_user_agent" do
        event = build(:analytics_event, request_user_agent: nil)
        expect(event).to be_valid
      end

      it "allows nil request_params" do
        event = build(:analytics_event, request_params: nil)
        expect(event).to be_valid
      end
    end

    context "with coordinate fields" do
      it "allows valid latitude" do
        event = build(:analytics_event, lat: 49.2827, long: -123.1207)
        expect(event).to be_valid
      end

      it "allows negative latitude" do
        event = build(:analytics_event, lat: -33.8688, long: 151.2093)
        expect(event).to be_valid
      end

      it "allows positive longitude" do
        event = build(:analytics_event, lat: 49.2827, long: 151.2093)
        expect(event).to be_valid
      end

      it "allows zero coordinates" do
        event = build(:analytics_event, lat: 0, long: 0)
        expect(event).to be_valid
      end

      it "allows very small coordinates" do
        event = build(:analytics_event, lat: 0.000001, long: -0.000001)
        expect(event).to be_valid
      end

      it "allows very large coordinates" do
        event = build(:analytics_event, lat: 90, long: 180)
        expect(event).to be_valid
      end
    end
  end

  describe "Associations" do
    it { is_expected.to belong_to(:visit) }
    it { is_expected.to have_many(:impressions).dependent(:destroy) }
    it { is_expected.to have_many(:facilities).through(:impressions).source(:impressionable) }

    context "with dependent destroy for impressions" do
      it "destroys associated impressions when event is destroyed" do
        event = create(:analytics_event)
        impression1 = create(:analytics_impression, event: event)
        impression2 = create(:analytics_impression, event: event)

        expect { event.destroy }.to change(Analytics::Impression, :count).by(-2)
        expect(Analytics::Impression.find_by(id: impression1.id)).to be_nil
        expect(Analytics::Impression.find_by(id: impression2.id)).to be_nil
      end
    end

    context "belongs_to visit" do
      it "can access associated visit" do
        visit = create(:analytics_visit)
        event = create(:analytics_event, visit: visit)

        expect(event.visit).to eq(visit)
        expect(visit.events).to include(event)
      end

      it "is invalid without associated visit" do
        event = build(:analytics_event, visit: nil)
        expect(event).not_to be_valid
      end
    end

    context "has_many impressions" do
      let(:event) { create(:analytics_event) }
      let!(:impression1) { create(:analytics_impression, event: event) }
      let!(:impression2) { create(:analytics_impression, event: event) }

      it "can access associated impressions" do
        expect(event.impressions).to contain_exactly(impression1, impression2)
      end

      it "orders impressions correctly" do
        # Test that impressions are returned in the expected order
        expect(event.impressions.first).to eq(impression1)
        expect(event.impressions.last).to eq(impression2)
      end
    end

    context "has_many facilities through impressions" do
      let(:event) { create(:analytics_event) }
      let!(:facility1) { create(:facility) }
      let!(:facility2) { create(:facility) }
      let!(:impression1) { create(:analytics_impression, event: event, impressionable: facility1) }
      let!(:impression2) { create(:analytics_impression, event: event, impressionable: facility2) }

      it "can access facilities through impressions" do
        expect(event.facilities).to contain_exactly(facility1, facility2)
      end

      it "correctly filters by source_type Facility" do
        # This tests the source_type specification in the through association
        service = create(:service)
        create(:analytics_impression, event: event, impressionable: service)

        # Should only return facilities, not services
        expect(event.facilities).to contain_exactly(facility1, facility2)
        expect(event.facilities).not_to include(service)

        # Verify that the association works correctly by checking the source_type
        # The through association should only return records where impressionable_type = 'Facility'
        expect(event.impressions.where(impressionable_type: "Facility").count).to eq(2)
        expect(event.impressions.where(impressionable_type: "Service").count).to eq(1)
      end

      it "returns empty array when no facility impressions exist" do
        event = create(:analytics_event)
        service = create(:service)
        create(:analytics_impression, event: event, impressionable: service)

        expect(event.facilities).to be_empty
      end

      it "handles duplicate facility impressions" do
        # Start with a clean event for this test
        clean_event = create(:analytics_event)

        # Create multiple impressions for the same facility
        facility = create(:facility)
        create(:analytics_impression, event: clean_event, impressionable: facility)

        # Creating a second impression for the same facility/event will fail due to uniqueness constraint
        expect do
          create(:analytics_impression, event: clean_event, impressionable: facility)
        end.to raise_error(ActiveRecord::RecordInvalid, /Impressionable has already been taken/)

        # Should still return the facility once - reload to ensure we're getting fresh data
        clean_event.reload
        expect(clean_event.facilities).to contain_exactly(facility)
      end
    end
  end

  describe "JSON request_params handling" do
    it "accepts hash for request_params" do
      params = { search: "test", page: 1, filters: { category: "sports" } }
      event = build(:analytics_event, request_params: params)

      expect(event).to be_valid
      # Rails converts symbol keys to strings in JSON columns
      expected_params = { "search" => "test", "page" => 1, "filters" => { "category" => "sports" } }
      expect(event.request_params).to eq(expected_params)
    end

    it "accepts string for request_params" do
      params = '{"search":"test","page":1}'
      event = build(:analytics_event, request_params: params)

      expect(event).to be_valid
      expect(event.request_params).to eq(params)
    end

    it "accepts empty hash for request_params" do
      event = build(:analytics_event, request_params: {})
      expect(event).to be_valid
      expect(event.request_params).to eq({})
    end

    it "accepts nil for request_params" do
      event = build(:analytics_event, request_params: nil)
      expect(event).to be_valid
      expect(event.request_params).to be_nil
    end

    it "accepts array for request_params" do
      params = [1, 2, 3]
      event = build(:analytics_event, request_params: params)

      expect(event).to be_valid
      expect(event.request_params).to eq(params)
    end

    it "accepts nested structures in request_params" do
      params = {
        search: "test",
        filters: {
          category: "sports",
          location: {
            lat: 49.2827,
            long: -123.1207
          }
        },
        sort: [{ field: "name", direction: "asc" }]
      }
      event = build(:analytics_event, request_params: params)

      expect(event).to be_valid
      # Rails converts symbol keys to strings in JSON columns
      expected_params = {
        "search" => "test",
        "filters" => {
          "category" => "sports",
          "location" => {
            "lat" => 49.2827,
            "long" => -123.1207
          }
        },
        "sort" => [{ "field" => "name", "direction" => "asc" }]
      }
      expect(event.request_params).to eq(expected_params)
    end
  end

  describe "URL format handling" do
    it "accepts HTTP URLs" do
      event = build(:analytics_event, request_url: "http://example.com/facilities")
      expect(event).to be_valid
    end

    it "accepts HTTPS URLs" do
      event = build(:analytics_event, request_url: "https://example.com/facilities")
      expect(event).to be_valid
    end

    it "accepts URLs with query parameters" do
      event = build(:analytics_event, request_url: "https://example.com/facilities?search=test&page=1")
      expect(event).to be_valid
    end

    it "accepts URLs with fragments" do
      event = build(:analytics_event, request_url: "https://example.com/facilities#section")
      expect(event).to be_valid
    end

    it "accepts localhost URLs" do
      event = build(:analytics_event, request_url: "http://localhost:3000/facilities")
      expect(event).to be_valid
    end

    it "accepts URLs with ports" do
      event = build(:analytics_event, request_url: "https://example.com:8080/facilities")
      expect(event).to be_valid
    end

    it "accepts relative URLs" do
      event = build(:analytics_event, request_url: "/facilities")
      expect(event).to be_valid
    end

    it "accepts root URL" do
      event = build(:analytics_event, request_url: "/")
      expect(event).to be_valid
    end
  end

  describe "User agent handling" do
    it "accepts typical browser user agents" do
      user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
      event = build(:analytics_event, request_user_agent: user_agent)
      expect(event).to be_valid
    end

    it "accepts mobile user agents" do
      user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Mobile/15E148 Safari/604.1"
      event = build(:analytics_event, request_user_agent: user_agent)
      expect(event).to be_valid
    end

    it "accepts API client user agents" do
      user_agent = "MyApp/1.0.0 (iOS; iPhone 13)"
      event = build(:analytics_event, request_user_agent: user_agent)
      expect(event).to be_valid
    end

    it "accepts empty string user agent" do
      event = build(:analytics_event, request_user_agent: "")
      expect(event).to be_valid
    end

    it "accepts very long user agents" do
      user_agent = "A" * 500
      event = build(:analytics_event, request_user_agent: user_agent)
      expect(event).to be_valid
    end

    it "accepts user agents with special characters" do
      user_agent = "Mozilla/5.0 (compatible; MyBot/1.0; +http://example.com/bot)"
      event = build(:analytics_event, request_user_agent: user_agent)
      expect(event).to be_valid
    end
  end

  describe "IP address handling" do
    it "accepts IPv4 addresses" do
      event = build(:analytics_event, request_ip: "192.168.1.1")
      expect(event).to be_valid
    end

    it "accepts IPv6 addresses" do
      event = build(:analytics_event, request_ip: "2001:0db8:85a3:0000:0000:8a2e:0370:7334")
      expect(event).to be_valid
    end

    it "accepts localhost IPv4" do
      event = build(:analytics_event, request_ip: "127.0.0.1")
      expect(event).to be_valid
    end

    it "accepts localhost IPv6" do
      event = build(:analytics_event, request_ip: "::1")
      expect(event).to be_valid
    end

    it "accepts private IP ranges" do
      event = build(:analytics_event, request_ip: "10.0.0.1")
      expect(event).to be_valid
    end

    it "accepts empty string IP" do
      event = build(:analytics_event, request_ip: "")
      expect(event).to be_valid
    end
  end

  describe "Timestamp behavior" do
    it "sets created_at and updated_at on creation" do
      event = create(:analytics_event)

      expect(event.created_at).to be_present
      expect(event.updated_at).to be_present
      expect(event.created_at).to be_within(1.second).of(event.updated_at)
    end

    it "updates updated_at on attribute update" do
      event = create(:analytics_event)
      original_updated_at = event.updated_at

      travel_to(1.minute.from_now) do
        event.update!(action_name: "edit")
        event.reload

        expect(event.updated_at).to be > original_updated_at
      end
    end

    it "does not update updated_at when no attributes change" do
      event = create(:analytics_event)
      original_updated_at = event.updated_at

      travel_to(1.minute.from_now) do
        event.reload
        expect(event.updated_at).to eq(original_updated_at)
      end
    end
  end

  describe "Edge cases" do
    it "handles very long controller names" do
      long_name = "a" * 255
      event = build(:analytics_event, controller_name: long_name)
      expect(event).to be_valid
    end

    it "handles very long action names" do
      long_name = "a" * 255
      event = build(:analytics_event, action_name: long_name)
      expect(event).to be_valid
    end

    it "handles very long URLs" do
      long_url = "https://example.com/#{'a' * 1000}"
      event = build(:analytics_event, request_url: long_url)
      expect(event).to be_valid
    end

    it "handles special characters in controller name" do
      event = build(:analytics_event, controller_name: "admin/api/v1/facilities")
      expect(event).to be_valid
    end

    it "handles special characters in action name" do
      event = build(:analytics_event, action_name: "bulk_update_status")
      expect(event).to be_valid
    end

    it "handles numeric strings in request_params" do
      params = { page: "1", limit: "10", price: "99.99" }
      event = build(:analytics_event, request_params: params)
      expect(event).to be_valid
      # Rails converts symbol keys to strings in JSON columns
      expected_params = { "page" => "1", "limit" => "10", "price" => "99.99" }
      expect(event.request_params).to eq(expected_params)
    end

    it "handles boolean values in request_params" do
      params = { active: true, featured: false }
      event = build(:analytics_event, request_params: params)
      expect(event).to be_valid
      # Rails converts symbol keys to strings in JSON columns
      expected_params = { "active" => true, "featured" => false }
      expect(event.request_params).to eq(expected_params)
    end

    it "handles null values in request_params hash" do
      params = { search: "test", category: nil }
      event = build(:analytics_event, request_params: params)
      expect(event).to be_valid
      # Rails converts symbol keys to strings in JSON columns
      expected_params = { "search" => "test", "category" => nil }
      expect(event.request_params).to eq(expected_params)
    end
  end

  describe "Database behavior" do
    it "persists event with all attributes" do
      visit = create(:analytics_visit)
      params = { search: "test", page: 1 }
      event = create(:analytics_event,
                     visit: visit,
                     controller_name: "facilities",
                     action_name: "show",
                     request_url: "https://example.com/facilities/1",
                     lat: 49.2827,
                     long: -123.1207,
                     request_ip: "192.168.1.1",
                     request_user_agent: "Test Browser",
                     request_params: params)

      persisted = described_class.find(event.id)

      expect(persisted.visit).to eq(visit)
      expect(persisted.controller_name).to eq("facilities")
      expect(persisted.action_name).to eq("show")
      expect(persisted.request_url).to eq("https://example.com/facilities/1")
      expect(persisted.lat).to eq(49.2827)
      expect(persisted.long).to eq(-123.1207)
      expect(persisted.request_ip).to eq("192.168.1.1")
      expect(persisted.request_user_agent).to eq("Test Browser")
      # Rails converts symbol keys to strings in JSON columns
      expected_params = { "search" => "test", "page" => 1 }
      expect(persisted.request_params).to eq(expected_params)
    end

    it "handles decimal precision for coordinates" do
      event = create(:analytics_event, lat: 49.2827345, long: -123.1207456)
      persisted = described_class.find(event.id)

      expect(persisted.lat).to eq(49.2827345)
      expect(persisted.long).to eq(-123.1207456)
    end
  end

  describe "Querying and scopes" do
    let(:visit1) { create(:analytics_visit) }
    let(:visit2) { create(:analytics_visit) }

    before do
      create(:analytics_event, visit: visit1, controller_name: "facilities", action_name: "index")
      create(:analytics_event, visit: visit1, controller_name: "facilities", action_name: "show")
      create(:analytics_event, visit: visit2, controller_name: "services", action_name: "index")
    end

    it "can find events by controller_name" do
      events = described_class.where(controller_name: "facilities")
      expect(events.count).to eq(2)
      expect(events.pluck(:action_name)).to contain_exactly("index", "show")
    end

    it "can find events by action_name" do
      events = described_class.where(action_name: "index")
      expect(events.count).to eq(2)
      expect(events.pluck(:controller_name)).to contain_exactly("facilities", "services")
    end

    it "can find events by visit" do
      events = described_class.where(visit: visit1)
      expect(events.count).to eq(2)
    end

    it "can chain queries" do
      events = described_class.where(controller_name: "facilities", action_name: "index")
      expect(events.count).to eq(1)
      expect(events.first.visit).to eq(visit1)
    end
  end
end
