# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::GoogleMaps::StaticMapService, type: :service do
  before do
    stub_const("Locations::GoogleMaps::GOOGLE_KEY", "test_google_key")
    stub_const("Locations::GoogleMaps::GOOGLE_SIGNATURE", "")
  end

  let(:latitude) { 49.243463359535 }
  let(:longitude) { -123.106431021296 }
  let(:service) { described_class.new(latitude, longitude) }

  describe "initialization" do
    it "initializes with latitude and longitude" do
      expect(service.latitude).to eq(latitude)
      expect(service.longitude).to eq(longitude)
    end

    it "creates a URI object with the correct base URL" do
      expect(service.uri).to be_a(URI::HTTPS)
      expect(service.uri.to_s).to start_with("https://maps.googleapis.com/maps/api/staticmap")
    end

    it "handles integer coordinates" do
      int_service = described_class.new(49, -123)
      expect(int_service.latitude).to eq(49)
      expect(int_service.longitude).to eq(-123)
    end

    it "handles float coordinates" do
      float_service = described_class.new(49.5, -123.5)
      expect(float_service.latitude).to eq(49.5)
      expect(float_service.longitude).to eq(-123.5)
    end

    it "handles string coordinates that can be converted to numbers" do
      string_service = described_class.new("49.243463", "-123.106431")
      expect(string_service.latitude).to eq("49.243463")
      expect(string_service.longitude).to eq("-123.106431")
    end

    it "handles nil coordinates" do
      nil_service = described_class.new(nil, nil)
      expect(nil_service.latitude).to be_nil
      expect(nil_service.longitude).to be_nil
    end
  end

  describe "#call" do
    let(:result) { service.call }

    it "returns a URI object" do
      expect(result).to be_a(URI::HTTPS)
    end

    it "has the correct hostname" do
      expect(result.hostname).to eq("maps.googleapis.com")
    end

    it "has the correct path" do
      expect(result.path).to eq("/maps/api/staticmap")
    end

    it "has the correct scheme" do
      expect(result.scheme).to eq("https")
    end

    it "sets query parameters" do
      expect(result.query).not_to be_nil
      expect(result.query).not_to be_empty
    end

    describe "query parameters" do
      let(:query_params) do
        URI.decode_www_form(result.query).to_h
      end

      it "includes center parameter with rounded coordinates" do
        expect(query_params["center"]).to eq("49.243463,-123.106431")
      end

      it "includes zoom parameter from MAP_CONFIG" do
        expect(query_params["zoom"]).to eq("14")
      end

      it "includes maptype parameter from MAP_CONFIG" do
        expect(query_params["maptype"]).to eq("roadmap")
      end

      it "includes size parameter from MAP_CONFIG" do
        expect(query_params["size"]).to eq("400x400")
      end

      it "includes markers parameter with correct format" do
        expect(query_params["markers"]).to eq("color:red|label:F|49.243463,-123.106431")
      end

      it "includes key parameter with GOOGLE_KEY" do
        expect(query_params["key"]).to eq("test_google_key")
      end

      it "does not include signature parameter when GOOGLE_SIGNATURE is blank" do
        expect(query_params).not_to have_key("signature")
      end

      context "when GOOGLE_SIGNATURE is present" do
        before do
          stub_const("Locations::GoogleMaps::GOOGLE_SIGNATURE", "test_signature")
        end

        it "includes signature parameter" do
          expect(query_params["signature"]).to eq("test_signature")
        end
      end
    end

    describe "coordinate rounding behavior" do
      context "with many decimal places" do
        let(:high_precision_lat) { 49.243463359535123456789 }
        let(:high_precision_long) { -123.106431021296123456789 }
        let(:high_precision_service) { described_class.new(high_precision_lat, high_precision_long) }

        it "rounds to 6 decimal places in center parameter" do
          result = high_precision_service.call
          query_params = URI.decode_www_form(result.query).to_h
          expect(query_params["center"]).to eq("49.243463,-123.106431")
        end

        it "rounds to 6 decimal places in markers parameter" do
          result = high_precision_service.call
          query_params = URI.decode_www_form(result.query).to_h
          expect(query_params["markers"]).to eq("color:red|label:F|49.243463,-123.106431")
        end
      end

      context "with coordinates that need rounding up" do
        let(:round_up_service) { described_class.new(49.2434635, -123.1064315) }

        it "rounds correctly" do
          result = round_up_service.call
          query_params = URI.decode_www_form(result.query).to_h
          expect(query_params["center"]).to eq("49.243464,-123.106432")
        end
      end

      context "with coordinates that need rounding down" do
        let(:round_down_service) { described_class.new(49.2434634, -123.1064314) }

        it "rounds correctly" do
          result = round_down_service.call
          query_params = URI.decode_www_form(result.query).to_h
          expect(query_params["center"]).to eq("49.243463,-123.106431")
        end
      end

      context "with negative coordinates" do
        let(:negative_service) { described_class.new(-49.243463359535, 123.106431021296) }

        it "handles negative coordinates correctly" do
          result = negative_service.call
          query_params = URI.decode_www_form(result.query).to_h
          expect(query_params["center"]).to eq("-49.243463,123.106431")
        end
      end

      context "with zero coordinates" do
        let(:zero_service) { described_class.new(0, 0) }

        it "handles zero coordinates correctly" do
          result = zero_service.call
          query_params = URI.decode_www_form(result.query).to_h
          expect(query_params["center"]).to eq("0,0")
        end
      end
    end

    describe "marker behavior" do
      it "includes color marker" do
        result = service.call
        query_params = URI.decode_www_form(result.query).to_h
        expect(query_params["markers"]).to include("color:red")
      end

      it "includes label marker" do
        result = service.call
        query_params = URI.decode_www_form(result.query).to_h
        expect(query_params["markers"]).to include("label:F")
      end

      it "includes coordinates in markers" do
        result = service.call
        query_params = URI.decode_www_form(result.query).to_h
        expect(query_params["markers"]).to include("49.243463,-123.106431")
      end

      it "separates marker components with pipes" do
        result = service.call
        query_params = URI.decode_www_form(result.query).to_h
        expect(query_params["markers"]).to eq("color:red|label:F|49.243463,-123.106431")
      end
    end

    describe "edge cases" do
      context "with nil coordinates" do
        let(:nil_service) { described_class.new(nil, nil) }

        it "raises error for nil coordinates" do
          expect { nil_service.call }.to raise_error(NoMethodError, /undefined method 'round' for nil/)
        end
      end

      context "with empty coordinates" do
        let(:empty_service) { described_class.new("", "") }

        it "raises error for empty coordinates" do
          expect do
            empty_service.call
          end.to raise_error(NoMethodError, /undefined method 'round' for an instance of String/)
        end
      end

      context "with very large coordinates" do
        let(:large_service) { described_class.new(999.999999, -999.999999) }

        it "handles large coordinates" do
          result = large_service.call
          query_params = URI.decode_www_form(result.query).to_h
          expect(query_params["center"]).to eq("999.999999,-999.999999")
        end
      end

      context "with very small coordinates" do
        let(:small_service) { described_class.new(0.0000001, -0.0000001) }

        it "handles very small coordinates" do
          result = small_service.call
          query_params = URI.decode_www_form(result.query).to_h
          expect(query_params["center"]).to eq("0.0,-0.0")
        end
      end
    end

    describe "URL encoding" do
      it "properly encodes query parameters" do
        result = service.call
        expect(result.query).to include("center=49.243463%2C-123.106431")
        expect(result.query).to include("markers=color%3Ared%7Clabel%3AF%7C49.243463%2C-123.106431")
      end

      it "creates a valid URI that can be parsed" do
        result = service.call
        parsed_uri = URI.parse(result.to_s)
        expect(parsed_uri).to eq(result)
      end

      it "creates a URI that can be accessed via HTTP" do
        result = service.call
        expect(result.to_s).to start_with("https://maps.googleapis.com")
        expect(result.to_s).to include("?")
      end
    end
  end

  describe "private methods" do
    describe "#coordinates" do
      it "returns an array with rounded latitude and longitude" do
        coordinates = service.send(:coordinates)
        expect(coordinates).to eq([49.243463, -123.106431])
      end

      it "rounds to 6 decimal places" do
        high_precision_service = described_class.new(49.243463359535, -123.106431021296)
        coordinates = high_precision_service.send(:coordinates)
        expect(coordinates).to eq([49.243463, -123.106431])
      end
    end

    describe "#markers" do
      it "returns an array with marker components" do
        markers = service.send(:markers)
        expect(markers).to eq(["color:red", "label:F", "49.243463,-123.106431"])
      end

      it "uses rounded coordinates" do
        high_precision_service = described_class.new(49.243463359535, -123.106431021296)
        markers = high_precision_service.send(:markers)
        expect(markers[2]).to eq("49.243463,-123.106431")
      end
    end

    describe "#query_params" do
      let(:query_params) { service.send(:query_params) }

      it "returns a hash with symbolized keys" do
        expect(query_params).to be_a(Hash)
        expect(query_params.keys).to all(be_a(Symbol))
      end

      it "includes all required parameters" do
        expect(query_params).to have_key(:center)
        expect(query_params).to have_key(:zoom)
        expect(query_params).to have_key(:maptype)
        expect(query_params).to have_key(:size)
        expect(query_params).to have_key(:markers)
        expect(query_params).to have_key(:key)
      end

      it "uses correct values from MAP_CONFIG" do
        expect(query_params[:zoom]).to eq(14)
        expect(query_params[:maptype]).to eq("roadmap")
        expect(query_params[:size]).to eq("400x400")
      end

      it "uses coordinates for center parameter" do
        expect(query_params[:center]).to eq("49.243463,-123.106431")
      end

      it "joins markers with pipe separator" do
        expect(query_params[:markers]).to eq("color:red|label:F|49.243463,-123.106431")
      end
    end
  end

  describe "class method interface" do
    it "can be called using .call class method" do
      result = described_class.call(latitude, longitude)
      expect(result).to be_a(URI::HTTPS)
    end

    it "class method returns same result as instance method" do
      instance_result = service.call
      class_result = described_class.call(latitude, longitude)

      expect(instance_result.to_s).to eq(class_result.to_s)
    end

    it "class method handles multiple arguments correctly" do
      result = described_class.call(40.7128, -74.0060)
      query_params = URI.decode_www_form(result.query).to_h
      expect(query_params["center"]).to eq("40.7128,-74.006")
    end
  end

  describe "integration with URI handling" do
    it "handles URI with no existing query parameters" do
      # This is the normal case
      result = service.call
      query_params = URI.decode_www_form(result.query).to_h

      expect(query_params).to have_key("center")
      expect(query_params).to have_key("zoom")
      expect(query_params).to have_key("markers")
      expect(query_params).to have_key("key")
    end
  end

  describe "error handling and validation" do
    context "when latitude is not numeric" do
      let(:invalid_lat_service) { described_class.new("invalid", -123.106431) }

      it "raises error for non-numeric latitude" do
        expect do
          invalid_lat_service.call
        end.to raise_error(NoMethodError, /undefined method 'round' for an instance of String/)
      end
    end

    context "when longitude is not numeric" do
      let(:invalid_long_service) { described_class.new(49.243463, "invalid") }

      it "raises error for non-numeric longitude" do
        expect do
          invalid_long_service.call
        end.to raise_error(NoMethodError, /undefined method 'round' for an instance of String/)
      end
    end

    context "when coordinates are extremely large" do
      let(:extreme_service) { described_class.new(Float::INFINITY, -Float::INFINITY) }

      it "handles extreme values" do
        expect { extreme_service.call }.not_to raise_error
        result = extreme_service.call
        expect(result).to be_a(URI::HTTPS)
      end
    end
  end

  describe "configuration independence" do
    it "uses the actual MAP_CONFIG values" do
      result = described_class.call(latitude, longitude)
      query_params = URI.decode_www_form(result.query).to_h

      expect(query_params["zoom"]).to eq("14")
      expect(query_params["size"]).to eq("400x400")
      expect(query_params["maptype"]).to eq("roadmap")
    end
  end
end
