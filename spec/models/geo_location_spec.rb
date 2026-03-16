# frozen_string_literal: true

require "rails_helper"

RSpec.describe GeoLocation do
  describe "Coord struct" do
    let(:lat) { 49.2827 }
    let(:long) { -123.1207 }
    let(:coord) { described_class::Coord.new(lat, long) }

    it "creates a Coord struct with lat and long" do
      expect(coord.lat).to eq(lat)
      expect(coord.long).to eq(long)
    end

    it "is a Struct instance" do
      expect(coord).to be_a(Struct)
    end

    it "has accessible lat and long attributes" do
      expect(coord[:lat]).to eq(lat)
      expect(coord[:long]).to eq(long)
    end
  end

  describe ".coord" do
    let(:lat) { 49.2827 }
    let(:long) { -123.1207 }

    it "returns a Coord struct" do
      result = described_class.coord(lat, long)
      expect(result).to be_a(described_class::Coord)
      expect(result.lat).to eq(lat)
      expect(result.long).to eq(long)
    end

    context "with nil values" do
      it "handles nil lat" do
        result = described_class.coord(nil, long)
        expect(result.lat).to be_nil
        expect(result.long).to eq(long)
      end

      it "handles nil long" do
        result = described_class.coord(lat, nil)
        expect(result.lat).to eq(lat)
        expect(result.long).to be_nil
      end
    end
  end

  describe ".distance" do
    let(:from_coord) { described_class.coord(49.2827, -123.1207) }
    let(:to_coord) { described_class.coord(49.2435, -123.1064) }
    let(:expected_distance) { 4.5 } # km

    before do
      allow(Haversine).to receive(:distance).and_return(expected_distance)
    end

    it "calls Haversine.distance with correct coordinates" do
      described_class.distance(from_coord, to_coord)

      expect(Haversine).to have_received(:distance).with(
        from_coord.lat, from_coord.long, to_coord.lat, to_coord.long
      )
    end

    it "returns the distance from Haversine" do
      result = described_class.distance(from_coord, to_coord)
      expect(result).to eq(expected_distance)
    end

    context "with same coordinates" do
      let(:same_coord) { described_class.coord(49.2827, -123.1207) }

      it "calculates distance of zero" do
        allow(Haversine).to receive(:distance).and_return(0.0)
        result = described_class.distance(same_coord, same_coord)
        expect(result).to eq(0.0)
      end
    end

    context "with nil coordinates" do
      it "handles nil from_coord gracefully" do
        expect do
          described_class.distance(nil, to_coord)
        end.to raise_error(NoMethodError) # because Haversine expects numeric
      end

      it "handles nil to_coord gracefully" do
        expect do
          described_class.distance(from_coord, nil)
        end.to raise_error(NoMethodError)
      end
    end
  end

  describe ".for_address" do
    let(:address) { "123 Main St, Vancouver, BC" }
    let(:params) { { countrycodes: "ca" } }
    let(:lat) { 49.2827 }
    let(:long) { -123.1207 }
    let(:coordinates) { [lat, long] }

    before do
      allow(Geocoder).to receive(:coordinates).and_return(coordinates)
    end

    it "calls Geocoder.coordinates with address and params" do
      described_class.for_address(address, params:)

      expect(Geocoder).to have_received(:coordinates).with(address, params)
    end

    it "returns a Coord struct with the coordinates" do
      result = described_class.for_address(address, params:)

      expect(result).to be_a(described_class::Coord)
      expect(result.lat).to eq(lat)
      expect(result.long).to eq(long)
    end

    context "with default params" do
      it "uses default countrycodes 'ca'" do
        described_class.for_address(address)

        expect(Geocoder).to have_received(:coordinates).with(address, { countrycodes: "ca" })
      end
    end

    context "when Geocoder returns nil" do
      before do
        allow(Geocoder).to receive(:coordinates).and_return(nil)
      end

      it "raises ArgumentError due to coord expecting 2 arguments" do
        expect do
          described_class.for_address(address)
        end.to raise_error(ArgumentError)
      end
    end

    context "when Geocoder raises an error" do
      before do
        allow(Geocoder).to receive(:coordinates).and_raise(StandardError, "Geocoding error")
      end

      it "propagates the error" do
        expect do
          described_class.for_address(address)
        end.to raise_error(StandardError, "Geocoding error")
      end
    end
  end

  describe ".search" do
    let(:args) { ["123 Main St, Vancouver, BC"] }
    let(:geocoder_results) { [instance_double(Geocoder::Result)] }

    before do
      allow(Geocoder).to receive(:search).and_return(geocoder_results)
    end

    it "calls Geocoder.search with the provided arguments" do
      described_class.search(*args)

      expect(Geocoder).to have_received(:search).with(*args)
    end

    it "returns the results from Geocoder.search" do
      result = described_class.search(*args)

      expect(result).to eq(geocoder_results)
    end

    context "with multiple arguments" do
      let(:args) { ["123 Main St", { countrycodes: "ca" }] }

      it "passes all arguments to Geocoder.search" do
        described_class.search(*args)

        expect(Geocoder).to have_received(:search).with("123 Main St", { countrycodes: "ca" })
      end
    end

    context "when Geocoder.search returns empty array" do
      before do
        allow(Geocoder).to receive(:search).and_return([])
      end

      it "returns empty array" do
        result = described_class.search(*args)

        expect(result).to eq([])
      end
    end

    context "when Geocoder.search raises an error" do
      before do
        allow(Geocoder).to receive(:search).and_raise(StandardError, "Search error")
      end

      it "propagates the error" do
        expect do
          described_class.search(*args)
        end.to raise_error(StandardError, "Search error")
      end
    end
  end
end
