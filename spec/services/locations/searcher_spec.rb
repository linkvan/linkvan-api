# frozen_string_literal: true

require "rails_helper"

GeocoderResultMock = Struct.new(:latitude, :longitude, :address, :state, :province, :country, :data, :city, :postal_code, :street_address)

RSpec.describe Locations::Searcher, type: :service do
  describe "initialization" do
    it "initializes with address parameter" do
      address = "123 Main St, Vancouver, BC"
      searcher = described_class.new(address:)

      expect(searcher.address).to eq(address)
    end

    it "initializes with nil address" do
      searcher = described_class.new(address: nil)

      expect(searcher.address).to be_nil
    end

    it "defaults address to nil when not provided" do
      searcher = described_class.new

      expect(searcher.address).to be_nil
    end
  end

  describe "#call" do
    let(:address) { "123 Main St, Vancouver, BC" }
    let(:searcher) { described_class.new(address:) }

    context "with successful geocoding" do
      let(:geocoder_result_one) do
        instance_double(Geocoder::Result::Base).tap do |double|
          allow(double).to receive_messages(latitude: 49.243463, longitude: -123.106431, address: "123 Main St", state: "BC", province: "British Columbia", country: "Canada", data: { "place_id" => "12345" })
        end
      end

      let(:geocoder_result_two) do
        instance_double(Geocoder::Result::Base).tap do |double|
          allow(double).to receive_messages(latitude: 49.243464, longitude: -123.106432, address: "123 Main Street", state: "BC", province: "British Columbia", country: "Canada", data: { "place_id" => "67890" })
        end
      end

      let(:parsed_location_one) do
        Locations::GeocoderLocation.new(
          address: "123 Main St",
          city: "Vancouver",
          state: "BC",
          country: "Canada",
          postal_code: "V6A 1A1",
          latitude: 49.243463,
          longitude: -123.106431,
          data: { "place_id" => "12345" },
          data_raw: '{"place_id":"12345"}'
        )
      end

      let(:parsed_location_two) do
        Locations::GeocoderLocation.new(
          address: "123 Main Street",
          city: "Vancouver",
          state: "BC",
          country: "Canada",
          postal_code: "V6A 1A2",
          latitude: 49.243464,
          longitude: -123.106432,
          data: { "place_id" => "67890" },
          data_raw: '{"place_id":"67890"}'
        )
      end

      let(:expected_location_one) do
        Location.build_from(geocoder_location: parsed_location_one)
      end

      let(:expected_location_two) do
        Location.build_from(geocoder_location: parsed_location_two)
      end

      before do
        allow(Geocoder).to receive(:search).with(address).and_return([geocoder_result_one, geocoder_result_two])
        allow(Locations::Parser).to receive(:parse).and_return(parsed_location_one, parsed_location_two)
        allow(Location).to receive(:build_from).and_return(expected_location_one, expected_location_two)
      end

      it "calls Geocoder.search with the address" do
        searcher.call
        expect(Geocoder).to have_received(:search).with(address)
      end

      it "returns a lazy enumerator" do
        result = searcher.call

        expect(result).to be_a(Enumerator::Lazy)
      end

      it "maps results through Locations::Parser.parse" do
        result = searcher.call
        result.to_a # Force evaluation

        expect(Locations::Parser).to have_received(:parse).with(geocoder_result_one)
        expect(Locations::Parser).to have_received(:parse).with(geocoder_result_two)
        expect(Location).to have_received(:build_from).with(geocoder_location: parsed_location_one)
        expect(Location).to have_received(:build_from).with(geocoder_location: parsed_location_two)
      end

      it "returns enumerable of Location objects" do
        result = searcher.call
        locations = result.to_a

        expect(locations).to eq([expected_location_one, expected_location_two])
        expect(locations.first).to be_a(Location)
        expect(locations.last).to be_a(Location)
      end

      describe "lazy enumeration behavior" do
        it "does not process results until enumeration" do
          searcher.call

          expect(Locations::Parser).not_to have_received(:parse)
          expect(Location).not_to have_received(:build_from)
        end

        it "processes results only as needed" do
          result = searcher.call

          # Process only the first element
          result.first

          expect(Locations::Parser).to have_received(:parse).with(geocoder_result_one).once
          expect(Locations::Parser).not_to have_received(:parse).with(geocoder_result_two)
          expect(Location).to have_received(:build_from).with(geocoder_location: parsed_location_one).once
          expect(Location).not_to have_received(:build_from).with(geocoder_location: parsed_location_two)
        end

        it "can be enumerated multiple times" do
          result = searcher.call

          # First enumeration
          first_enumeration = result.to_a
          expect(first_enumeration).to be_an(Array)
          expect(first_enumeration.length).to eq(2)

          # Second enumeration - should also work and return results
          second_enumeration = result.to_a
          expect(second_enumeration).to be_an(Array)
          expect(second_enumeration.length).to eq(2)

          # Both should contain Location objects
          expect(first_enumeration.all? { |loc| loc.is_a?(Location) }).to be true
          expect(second_enumeration.all? { |loc| loc.is_a?(Location) }).to be true
        end
      end
    end

    context "with single result" do
      let(:geocoder_result) do
        instance_double(Geocoder::Result::Base).tap do |double|
          allow(double).to receive_messages(latitude: 49.243463, longitude: -123.106431, address: "123 Main St", state: "BC", province: "British Columbia", country: "Canada", data: {})
        end
      end

      let(:parsed_location) do
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

      let(:expected_location) do
        Location.build_from(geocoder_location: parsed_location)
      end

      before do
        allow(Geocoder).to receive(:search).with(address).and_return([geocoder_result])
        allow(Locations::Parser).to receive(:parse).and_return(parsed_location)
        allow(Location).to receive(:build_from).and_return(expected_location)
      end

      it "returns single location object" do
        result = searcher.call
        locations = result.to_a

        expect(locations).to eq([expected_location])
        expect(locations.length).to eq(1)
      end

      it "can be accessed with first" do
        result = searcher.call
        location = result.first

        expect(location).to eq(expected_location)
      end
    end

    context "with empty results" do
      before do
        allow(Geocoder).to receive(:search).with(address).and_return([])
        allow(Locations::Parser).to receive(:parse)
        allow(Location).to receive(:build_from)
      end

      it "returns empty lazy enumerator" do
        result = searcher.call

        expect(result).to be_a(Enumerator::Lazy)
        expect(result.to_a).to be_empty
      end

      it "does not call Locations::Parser" do
        result = searcher.call
        result.to_a

        expect(Locations::Parser).not_to have_received(:parse)
      end

      it "does not call Location.build_from" do
        result = searcher.call
        result.to_a

        expect(Location).not_to have_received(:build_from)
      end
    end

    context "with nil address" do
      let(:nil_address_searcher) { described_class.new(address: nil) }

      before do
        allow(Geocoder).to receive(:search).with(nil).and_return([])
      end

      it "handles nil address gracefully" do
        result = nil_address_searcher.call
        expect(result).to be_a(Enumerator::Lazy)
        expect(result.to_a).to be_empty
      end

      it "calls Geocoder.search with nil" do
        nil_address_searcher.call

        expect(Geocoder).to have_received(:search).with(nil)
      end
    end

    context "with invalid address" do
      let(:invalid_address) { "" }
      let(:invalid_address_searcher) { described_class.new(address: invalid_address) }

      before do
        allow(Geocoder).to receive(:search).with(invalid_address).and_return([])
      end

      it "handles invalid address gracefully" do
        result = invalid_address_searcher.call
        expect(result).to be_a(Enumerator::Lazy)
        expect(result.to_a).to be_empty
      end

      it "calls Geocoder.search with invalid address" do
        invalid_address_searcher.call

        expect(Geocoder).to have_received(:search).with(invalid_address)
      end
    end

    context "when handling errors" do
      context "when Geocoder.search raises an error" do
        before do
          allow(Geocoder).to receive(:search).with(address).and_raise(StandardError, "Geocoder error")
        end

        it "propagates the error" do
          expect do
            searcher.call
          end.to raise_error(StandardError, "Geocoder error")
        end
      end

      context "when Locations::Parser.parse raises an error" do
        let(:geocoder_result) { instance_double(Geocoder::Result::Base) }

        before do
          allow(Geocoder).to receive(:search).with(address).and_return([geocoder_result])
          allow(Locations::Parser).to receive(:parse).with(geocoder_result).and_raise(StandardError, "Parser error")
        end

        it "propagates the error when enumeration occurs" do
          result = searcher.call

          expect do
            result.to_a
          end.to raise_error(StandardError, "Parser error")
        end

        it "does not raise error before enumeration due to lazy evaluation" do
          expect do
            searcher.call
          end.not_to raise_error
        end
      end

      context "when Location.build_from raises an error" do
        let(:geocoder_result) { instance_double(Geocoder::Result::Base) }
        let(:parsed_location) { instance_double(Locations::GeocoderLocation) }

        before do
          allow(Geocoder).to receive(:search).with(address).and_return([geocoder_result])
          allow(Locations::Parser).to receive(:parse).with(geocoder_result).and_return(parsed_location)
          allow(Location).to receive(:build_from).with(geocoder_location: parsed_location).and_raise(StandardError, "Build error")
        end

        it "propagates the error when enumeration occurs" do
          result = searcher.call

          expect do
            result.to_a
          end.to raise_error(StandardError, "Build error")
        end
      end
    end

    context "with Locations::Parser integration" do
      let(:geocoder_result) do
        instance_double(Geocoder::Result::Base).tap do |double|
          allow(double).to receive_messages(latitude: 49.243463, longitude: -123.106431, address: "123 Main St", state: "BC", province: "British Columbia", country: "Canada", data: { "provider" => "test" })
        end
      end

      let(:parsed_location) do
        Locations::GeocoderLocation.new(
          address: "123 Main St",
          city: "Vancouver",
          state: "BC",
          country: "Canada",
          postal_code: "V6A 1A1",
          latitude: 49.243463,
          longitude: -123.106431,
          data: { "provider" => "test" },
          data_raw: '{"provider":"test"}'
        )
      end

      let(:expected_location) do
        Location.build_from(geocoder_location: parsed_location)
      end

      before do
        allow(Geocoder).to receive(:search).with(address).and_return([geocoder_result])
        allow(Location).to receive(:build_from).with(geocoder_location: parsed_location).and_return(expected_location)
      end

      it "calls Locations::Parser.parse with correct parameters" do
        allow(Locations::Parser).to receive(:parse).and_call_original
        allow(Locations::Parser).to receive(:provider_class).and_return(class_double(Locations::Providers::BaseParser, call: parsed_location))

        result = searcher.call
        result.to_a

        expect(Locations::Parser).to have_received(:parse).with(geocoder_result)
      end

      it "uses parsed location to build final Location object" do
        allow(Locations::Parser).to receive(:parse).with(geocoder_result).and_return(parsed_location)

        result = searcher.call
        locations = result.to_a

        expect(locations).to eq([expected_location])
      end
    end

    context "with Location.build_from integration" do
      let(:geocoder_result) do
        instance_double(Geocoder::Result::Base).tap do |double|
          allow(double).to receive_messages(latitude: 49.243463, longitude: -123.106431, address: "123 Main St", state: "BC", province: "British Columbia", country: "Canada", data: {})
        end
      end

      let(:parsed_location) do
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

      let(:built_location) do
        Location.new(
          address: "123 Main St, Vancouver, BC, V6A 1A1, Canada",
          lat: 49.243463,
          long: -123.106431
        )
      end

      before do
        allow(Geocoder).to receive(:search).with(address).and_return([geocoder_result])
        allow(Locations::Parser).to receive(:parse).with(geocoder_result).and_return(parsed_location)
        allow(Location).to receive(:build_from).with(geocoder_location: parsed_location).and_call_original
      end

      it "calls Location.build_from with correct geocoder_location parameter" do
        result = searcher.call
        result.to_a

        expect(Location).to have_received(:build_from).with(geocoder_location: parsed_location)
      end

      it "returns properly built Location objects" do
        result = searcher.call
        locations = result.to_a

        expect(locations.first.address).to eq("123 Main St, Vancouver, BC, V6A 1A1")
        expect(locations.first.lat).to eq(49.243463)
        expect(locations.first.long).to eq(-123.106431)
      end
    end
  end

  describe "performance aspects" do
    let(:address) { "123 Main St, Vancouver, BC" }
    let(:searcher) { described_class.new(address:) }

    context "with lazy evaluation performance" do
      let(:geocoder_results) do
        Array.new(1000) do |i|
          GeocoderResultMock.new(
            49.243463 + (i * 0.001),
            -123.106431 + (i * 0.001),
            "123 Main St #{i}",
            "BC",
            "British Columbia",
            "Canada",
            { "index" => i },
            "Vancouver",
            "V6A 1A#{i}",
            "123 Main St #{i}"
          )
        end
      end

      before do
        allow(Geocoder).to receive(:search).with(address).and_return(geocoder_results)
        allow(Locations::Parser).to receive(:parse).and_return(instance_double(Locations::GeocoderLocation))
        allow(Location).to receive(:build_from).and_return(instance_double(Location))
      end

      it "does not process all results immediately" do
        # Instead of expecting not to receive, we'll verify that the methods were called only as many times as needed
        allow(Locations::Parser).to receive(:parse).and_call_original
        allow(Location).to receive(:build_from).and_call_original

        result = searcher.call
        # Process only first 5 elements
        result.first(5).to_a

        expect(Locations::Parser).to have_received(:parse).exactly(5).times
        expect(Location).to have_received(:build_from).exactly(5).times
      end

      it "processes only requested number of results" do
        result = searcher.call
        result.first(3).to_a

        expect(Locations::Parser).to have_received(:parse).exactly(3).times
        expect(Location).to have_received(:build_from).exactly(3).times
      end
    end

    context "with memory efficiency" do
      let(:large_result_set) { Array.new(10_000) { instance_double(Geocoder::Result::Base) } }

      before do
        allow(Geocoder).to receive(:search).with(address).and_return(large_result_set)
        allow(Locations::Parser).to receive(:parse).and_return(instance_double(Locations::GeocoderLocation))
        allow(Location).to receive(:build_from).and_return(instance_double(Location))
      end

      it "can handle large result sets without immediate memory overhead" do
        result = searcher.call

        # Should not attempt to process all 10,000 results immediately
        expect(result).to be_a(Enumerator::Lazy)
      end
    end
  end

  describe "class method shortcut" do
    it "can be called with .class method" do
      address = "123 Main St, Vancouver, BC"

      allow(Geocoder).to receive(:search).with(address).and_return([])

      described_class.call(address: address)

      expect(Geocoder).to have_received(:search).with(address)
    end

    it "works with the same interface as instance call" do
      address = "123 Main St, Vancouver, BC"

      allow(Geocoder).to receive(:search).with(address).and_return([])

      class_result = described_class.call(address: address)
      instance_result = described_class.new(address: address).call

      expect(class_result).to be_a(Enumerator::Lazy)
      expect(instance_result).to be_a(Enumerator::Lazy)
      expect(class_result.to_a).to eq(instance_result.to_a)
    end
  end
end
