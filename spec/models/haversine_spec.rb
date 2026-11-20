# frozen_string_literal: true

require "rails_helper"

RSpec.describe Haversine do
  describe ".distance" do
    subject(:distance) { described_class.distance(origin_lat, origin_long, target_lat, target_long) }

    # Two points in Vancouver, BC, roughly 4.48 km apart.
    let(:origin_lat) { 49.2827 }
    let(:origin_long) { -123.1207 }
    let(:target_lat) { 49.2435 }
    let(:target_long) { -123.1064 }

    it "returns a Distance value object" do
      expect(distance).to be_a(described_class::Distance)
    end

    it "computes the great circle distance in kilometers" do
      expect(distance.to_km).to be_within(0.001).of(4.4807)
    end

    it "computes the great circle distance in meters" do
      expect(distance.to_meters).to be_within(1).of(4480.65)
    end

    it "computes the great circle distance in miles" do
      expect(distance.to_miles).to be_within(0.001).of(2.7822)
    end

    it "computes the great circle distance in feet" do
      expect(distance.to_feet).to be_within(1).of(14_690.07)
    end

    it "computes the great circle distance in nautical miles" do
      expect(distance.to_nautical_miles).to be_within(0.001).of(2.4177)
    end

    it "exposes the raw angular distance" do
      expect(distance.great_circle_distance).to be_within(0.000001).of(0.000703)
    end

    context "when both points are the same" do
      it "returns zero distance" do
        expect(described_class.distance(origin_lat, origin_long, origin_lat, origin_long).to_km)
          .to be_within(0.000001).of(0)
      end
    end

    context "when the points are swapped" do
      it "returns the same distance" do
        forward = described_class.distance(origin_lat, origin_long, target_lat, target_long)
        backward = described_class.distance(target_lat, target_long, origin_lat, origin_long)

        expect(forward.to_km).to be_within(0.000001).of(backward.to_km)
      end
    end

    context "with one degree of longitude on the equator" do
      it "returns one degree of great circle arc" do
        expect(described_class.distance(0, 0, 0, 1).to_km).to be_within(0.0001).of(111.1949)
      end
    end

    context "with one degree of latitude" do
      it "returns one degree of great circle arc" do
        expect(described_class.distance(0, 0, 1, 0).to_km).to be_within(0.0001).of(111.1949)
      end
    end

    context "with missing coordinates" do
      it "raises ArgumentError" do
        expect { described_class.distance(origin_lat, origin_long, target_lat) }
          .to raise_error(ArgumentError)
      end
    end

    context "with nil coordinates" do
      it "raises ArgumentError" do
        expect { described_class.distance(origin_lat, origin_long, nil, target_long) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe "Haversine::Distance" do
    subject(:distance) { described_class.distance(0, 0, 0, 1) }

    it "aliases the kilometer conversion" do
      expect(distance.to_kilometers).to eq(distance.to_km)
    end

    it "aliases the mile conversion" do
      expect(distance.to_mi).to eq(distance.to_miles)
    end

    it "aliases the meter conversion" do
      expect(distance.to_m).to eq(distance.to_meters)
    end

    it "aliases the feet conversion" do
      expect(distance.to_ft).to eq(distance.to_feet)
    end

    it "aliases the nautical mile conversion" do
      expect(distance.to_nm).to eq(distance.to_nautical_miles)
    end

    it "is comparable with another distance" do
      shorter = described_class.distance(0, 0, 0, 0.5)

      expect(shorter).to be < distance
    end

    it "is not comparable with a non-distance" do
      expect(distance <=> 42).to be_nil
    end
  end
end
