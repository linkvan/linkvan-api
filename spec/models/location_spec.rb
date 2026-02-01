# frozen_string_literal: true

require "rails_helper"

RSpec.describe Location, type: :model do
  let(:address) { "123 Main St, Vancouver, BC" }
  let(:lat) { 49.243463 }
  let(:long) { -123.106431 }
  let(:facility) { build(:facility, :with_verified) }

  describe "ActiveModel::Naming" do
    it "extends ActiveModel::Naming" do
      expect(described_class.singleton_class.included_modules).to include(ActiveModel::Naming)
    end

    it "has correct model_name" do
      expect(described_class.model_name.name).to eq("Location")
    end

    it "responds to model_name" do
      expect(described_class).to respond_to(:model_name)
    end
  end

  describe "initialization" do
    subject(:location) { described_class.new(address:, lat:, long:, facility:) }

    it "sets address" do
      expect(location.address).to eq(address)
    end

    it "sets lat" do
      expect(location.lat).to eq(lat)
    end

    it "sets long" do
      expect(location.long).to eq(long)
    end

    it "sets facility" do
      expect(location.facility).to eq(facility)
    end

    context "without facility" do
      subject(:location) { described_class.new(address:, lat:, long:) }

      it "sets facility to nil" do
        expect(location.facility).to be_nil
      end
    end

    it "raises ArgumentError if address is missing" do
      expect { described_class.new(lat:, long:) }.to raise_error(ArgumentError)
    end

    it "raises ArgumentError if lat is missing" do
      expect { described_class.new(address:, long:) }.to raise_error(ArgumentError)
    end

    it "raises ArgumentError if long is missing" do
      expect { described_class.new(address:, lat:) }.to raise_error(ArgumentError)
    end
  end

  describe ".build" do
    let(:params) { { address:, lat:, long:, facility: } }

    it "creates a new Location instance" do
      location = described_class.build(params)

      expect(location).to be_a(described_class)
      expect(location.address).to eq(address)
      expect(location.lat).to eq(lat)
      expect(location.long).to eq(long)
      expect(location.facility).to eq(facility)
    end

    it "symbolizes keys" do
      string_params = { "address" => address, "lat" => lat, "long" => long, "facility" => facility }
      location = described_class.build(string_params)

      expect(location.address).to eq(address)
    end
  end

  describe ".build_from" do
    context "with geocoder_location" do
      let(:geocoder_location) do
        Locations::GeocoderLocation.new(
          address: "123 Main St",
          city: "Vancouver",
          state: "BC",
          country: "Canada",
          postal_code: "V6A 1A1",
          latitude: 49.243463,
          longitude: -123.106431,
          data: {},
          data_raw: "{}"
        )
      end

      let(:expected_address) { "123 Main St, Vancouver, BC, V6A 1A1" }

      it "creates Location from geocoder_location" do
        location = described_class.build_from(geocoder_location:)

        expect(location).to be_a(described_class)
        expect(location.address).to eq(expected_address)
        expect(location.lat).to eq(49.243463)
        expect(location.long).to eq(-123.106431)
        expect(location.facility).to be_nil
      end

      context "with nil components" do
        let(:geocoder_location) do
          Locations::GeocoderLocation.new(
            address: nil,
            city: "Vancouver",
            state: "BC",
            country: nil,
            postal_code: "V6A 1A1",
            latitude: 49.243463,
            longitude: -123.106431,
            data: {},
            data_raw: "{}"
          )
        end

        let(:expected_address) { "Vancouver, BC, V6A 1A1" }

        it "filters out nil components" do
          location = described_class.build_from(geocoder_location:)

          expect(location.address).to eq(expected_address)
        end
      end
    end

    context "with facility" do
      let(:facility) { build(:facility, :with_verified) }
      let(:expected_address) { facility.address }

      it "creates Location from facility" do
        location = described_class.build_from(facility:)

        expect(location).to be_a(described_class)
        expect(location.address).to eq(expected_address)
        expect(location.lat).to eq(facility.lat)
        expect(location.long).to eq(facility.long)
        expect(location.facility).to eq(facility)
      end
    end

    context "with both geocoder_location and facility" do
      let(:geocoder_location) { instance_double(Locations::GeocoderLocation) }
      let(:facility) { build(:facility, :with_verified) }

      it "raises ArgumentError" do
        expect do
          described_class.build_from(geocoder_location:, facility:)
        end.to raise_error(ArgumentError)
      end
    end

    context "with neither geocoder_location nor facility" do
      it "raises ArgumentError" do
        expect do
          described_class.build_from(geocoder_location: nil, facility: nil)
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe "#to_key" do
    subject(:location) { described_class.new(address:, lat:, long:) }

    it "returns array with coordinates hash" do
      expected_hash = [lat, long].hash
      expect(location.to_key).to eq([expected_hash])
    end

    it "is consistent for same coordinates" do
      location2 = described_class.new(address: "different", lat:, long:)
      expect(location.to_key).to eq(location2.to_key)
    end

    it "differs for different coordinates" do
      location2 = described_class.new(address:, lat: lat + 1, long:)
      expect(location.to_key).not_to eq(location2.to_key)
    end
  end

  describe "#persisted?" do
    context "when facility has id" do
      let(:facility) { build(:facility, :with_verified).tap { |f| f.id = 1 } }

      subject(:location) { described_class.new(address:, lat:, long:, facility:) }

      it "returns true" do
        expect(location).to be_persisted
      end
    end

    context "when facility is nil" do
      subject(:location) { described_class.new(address:, lat:, long:) }

      it "returns false" do
        expect(location).not_to be_persisted
      end
    end

    context "when facility has no id" do
      let(:facility) { build(:facility, :with_verified, id: nil) }

      subject(:location) { described_class.new(address:, lat:, long:, facility:) }

      it "returns false" do
        expect(location).not_to be_persisted
      end
    end
  end

  describe "#coordinates" do
    subject(:location) { described_class.new(address:, lat:, long:) }

    it "returns array of lat and long" do
      expect(location.coordinates).to eq([lat, long])
    end
  end

  describe "#distance_from" do
    subject(:location) { described_class.new(address:, lat:, long:) }

    let(:other_lat) { 49.2827 }
    let(:other_long) { -123.1207 }
    let(:distance) { 4.5 }

    before do
      allow(Haversine).to receive(:distance).and_return(distance)
    end

    it "calls Haversine.distance with correct arguments" do
      location.distance_from(other_lat, other_long)

      expect(Haversine).to have_received(:distance).with(lat, long, other_lat, other_long)
    end

    it "returns the distance" do
      result = location.distance_from(other_lat, other_long)

      expect(result).to eq(distance)
    end

    it "handles multiple coordinates" do
      coords = [other_lat, other_long, 49.3, -123.1]
      location.distance_from(*coords)

      expect(Haversine).to have_received(:distance).with(lat, long, *coords)
    end
  end

  describe "edge cases" do
    describe "address construction in build_from" do
      context "with facility having nil address components" do
        let(:facility) { build(:facility, :with_verified, address: nil) }

        it "handles nil address gracefully" do
          location = described_class.build_from(facility:)

          expect(location.address).to eq("")
        end
      end
    end

    describe "coordinates with float precision" do
      let(:lat) { 49.243463123456 }
      let(:long) { -123.106431987654 }

      subject(:location) { described_class.new(address:, lat:, long:) }

      it "preserves float precision" do
        expect(location.lat).to eq(lat)
        expect(location.long).to eq(long)
      end
    end
  end
end
