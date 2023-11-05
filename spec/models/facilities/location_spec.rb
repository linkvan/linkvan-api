require "rails_helper"

RSpec.describe FacilityLocation, type: :model do
  # subject(:location) { facility.location }
# 
  # let(:facility) { build(:facility) }

  describe ".search" do
    context "when searching by address" do
      subject(:search) { described_class.search(address: address) }

      let(:returned_location) { search.first }
      # let(:coordinates) { search.first.coordinates }

      # let(:address) { "160 Shoreline Circle, Port Moody, BC, Canada" }
      let(:address) { "#{expected_address}, Burnaby, BC, Canada" }
      let(:expected_address) { "3866 Evergreen Place" }

      context "with geocoder_ca provider" do
        let(:expected_latitude) { 49.250090150000005 }
        let(:expected_longitude) { -122.89352554999999 }

        before do
          Geocoder.configure(
            lookup: :geocoder_ca
          )
        end

        it "assigns locations for each returned location" do
          expect(search.count).to eq(1)

          # expect(returned_location.coordinates).to eq([expected_latitude, expected_longitude])
          expect(returned_location.address).to eq("3866 Evergreen Place")
          expect(returned_location.city).to eq("Burnaby")
          expect(returned_location.latitude).to be_within(0.0001).of(expected_latitude)
          expect(returned_location.longitude).to be_within(0.0001).of(expected_longitude)
        end

        it { expect(returned_location).to eq("TESTING data") }
        # it { expect(data).to eq("TESTING data") }
      end

      context "with nominatim provider" do
        let(:expected_latitude) { 49.250090150000005 }
        let(:expected_longitude) { -122.89352554999999 }

        before do
          Geocoder.configure(
            lookup: :nominatim
          )
        end

        it "assigns locations for each returned location" do
          expect(search.count).to eq(1)

          # expect(returned_location.coordinates).to eq([expected_latitude, expected_longitude])
          expect(returned_location.address).to eq("3866 Evergreen Place")
          expect(returned_location.city).to eq("Burnaby")
          expect(returned_location.latitude).to be_within(0.0001).of(expected_latitude)
          expect(returned_location.longitude).to be_within(0.0001).of(expected_longitude)
        end
      end

      context "with photon provider" do
        let(:expected_latitude) { 49.250090150000005 }
        let(:expected_longitude) { -122.89352554999999 }

        before do
          Geocoder.configure(
            lookup: :photon
          )
        end

        it "assigns locations for each returned location" do
          # Photon returns multiple entries for this address
          # expect(search.count).to eq(1)

          expect(returned_location.address).to eq("3866 Evergreen Place")
          expect(returned_location.city).to eq("Burnaby")
          expect(returned_location.latitude).to be_within(0.0001).of(expected_latitude)
          expect(returned_location.longitude).to be_within(0.0001).of(expected_longitude)
          # Confirms Location#data is parsed a Hash
          expect(returned_location.data).to have_key(:geometry)
        end
      end

      context "with google provider" do
        let(:expected_latitude) { 49.250090150000005 }
        let(:expected_longitude) { -122.89352554999999 }

        before do
          Geocoder.configure(
            lookup: :google
          )
        end

        it "assigns locations for each returned location" do
          # Photon returns multiple entries for this address
          # expect(search.count).to eq(1)

          expect(returned_location.address).to eq("3866 Evergreen Place")
          expect(returned_location.city).to eq("Burnaby")
          expect(returned_location.latitude).to be_within(0.0001).of(expected_latitude)
          expect(returned_location.longitude).to be_within(0.0001).of(expected_longitude)
        end
      end

    end
  end
end

