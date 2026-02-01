# frozen_string_literal: true

require "rails_helper"

RSpec.describe External::VancouverCity::Syncer, type: :service do
  subject(:syncer) { described_class.new(api_key: api_key, api_client: api_client) }

  let(:api_key) { "drinking-fountains" }
  let(:api_client) do
    client = double("VancouverApiClient")
    allow(client).to receive(:is_a?).with(External::VancouverCity::VancouverApiClient).and_return(true)
    client
  end
  let(:page_size) { described_class::PAGE_SIZE }

  # Mock Rails.logger
  before do
    allow(Rails).to receive(:logger).and_return(logger)
  end

  let(:logger) { instance_double(ActiveSupport::Logger) }

  describe "#initialize" do
    it "sets api_key and api_client attributes" do
      expect(syncer.api_key).to eq(api_key)
      expect(syncer.api_client).to eq(api_client)
    end

    it "inherits from ApplicationService" do
      expect(syncer).to be_a(ApplicationService)
    end

    it "responds to call method" do
      expect(syncer).to respond_to(:call)
    end
  end

  describe "#validate" do
    context "with valid parameters" do
      it "returns no errors" do
        expect(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)

        errors = syncer.validate
        expect(errors).to be_empty
      end
    end

    context "with unsupported API key" do
      let(:api_key) { "unsupported-api" }

      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(false)
      end

      it "adds API validation error" do
        errors = syncer.validate
        expect(errors).to include("Unsupported API: unsupported-api")
      end
    end

    context "with nil API client" do
      let(:api_client) { nil }

      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
      end

      it "adds API client validation error" do
        errors = syncer.validate
        expect(errors).to include("API client is required")
      end
    end

    context "with wrong API client type" do
      let(:api_client) { "wrong_type" }

      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
      end

      it "adds API client type validation error" do
        errors = syncer.validate
        expect(errors).to include("API client must be an instance of VancouverApiClient")
      end
    end

    context "with multiple validation errors" do
      let(:api_key) { "unsupported-api" }
      let(:api_client) { nil }

      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(false)
      end

      it "adds all validation errors" do
        errors = syncer.validate
        expect(errors).to include(
          "Unsupported API: unsupported-api",
          "API client is required"
        )
      end
    end
  end

  describe "#call" do
    context "when validation fails" do
      before do
        allow(syncer).to receive_messages(invalid?: true, errors: ["Validation error"])
      end

      it "returns failure result with validation errors" do
        result = syncer.call
        expect(result.success?).to be false
        expect(result.errors).to include("Validation error")
        expect(result.data).to be_nil
      end
    end

    context "when validation succeeds" do
      let(:sample_records) do
        [
          { "name" => "Fountain 1", "lat" => 49.2827, "long" => -123.1207 },
          { "name" => "Fountain 2", "lat" => 49.2828, "long" => -123.1208 }
        ]
      end

      let(:sample_facility) { instance_double(Facility) }
      let(:syncer_result) do
        ApplicationService::Result.new(
          data: { facility: sample_facility },
          errors: []
        )
      end

      let(:api_client) do
        client = double("VancouverApiClient")
        allow(client).to receive(:is_a?).with(External::VancouverCity::VancouverApiClient).and_return(true)
        client
      end

      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
        allow(External::VancouverCity::FacilitySyncer).to receive(:call).and_return(syncer_result)
        allow(logger).to receive(:info)
        allow(logger).to receive(:warn)
      end

      context "with empty API response" do
        before do
          empty_response = instance_double(Faraday::Response, body: { "results" => [] })
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_return(empty_response)
        end

        it "logs fetch request and processes no facilities" do
          expect(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
          expect(logger).to receive(:info).with("Successfully processed 0 facilities from #{api_key} API")

          result = syncer.call

          expect(result.success?).to be true
          expect(result.data[:facilities]).to be_empty
          expect(result.data[:total_count]).to eq(0)
          expect(result.data[:api_key]).to eq(api_key)
        end
      end

      context "with single page of results" do
        let(:response) do
          instance_double(Faraday::Response, body: { "results" => sample_records })
        end

        before do
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_return(response)
        end

        it "processes records and returns success result" do
          expect(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
          expect(External::VancouverCity::FacilitySyncer).to receive(:call).twice
          expect(logger).to receive(:info).with("Successfully processed 2 facilities from #{api_key} API")

          result = syncer.call

          expect(result.success?).to be true
          expect(result.data[:facilities]).to contain_exactly(sample_facility, sample_facility)
          expect(result.data[:total_count]).to eq(2)
          expect(result.data[:api_key]).to eq(api_key)
        end
      end

      context "with multiple pages of results" do
        let(:first_response) do
          instance_double(Faraday::Response, body: { "results" => full_page_records })
        end

        let(:full_page_records) { Array.new(page_size) { |i| { "name" => "Fountain #{i}" } } }

        let(:second_response) do
          instance_double(Faraday::Response, body: { "results" => [] })
        end

        before do
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_return(first_response)

          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: page_size)
            .and_return(second_response)
        end

        it "fetches all pages and processes all records" do
          expect(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
          expect(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: #{page_size}, limit: #{page_size})")
          expect(External::VancouverCity::FacilitySyncer).to receive(:call).exactly(page_size).times
          expect(logger).to receive(:info).with("Successfully processed #{page_size} facilities from #{api_key} API")

          result = syncer.call

          expect(result.success?).to be true
          expect(result.data[:total_count]).to eq(page_size)
        end
      end

      context "when exactly PAGE_SIZE records are returned" do
        let(:full_page_records) { Array.new(page_size) { |i| { "name" => "Fountain #{i}" } } }
        let(:full_page_response) do
          instance_double(Faraday::Response, body: { "results" => full_page_records })
        end

        let(:empty_response) do
          instance_double(Faraday::Response, body: { "results" => [] })
        end

        before do
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_return(full_page_response)

          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: page_size)
            .and_return(empty_response)

          # Mock FacilitySyncer for all records
          allow(External::VancouverCity::FacilitySyncer).to receive(:call).and_return(syncer_result)
        end

        it "continues pagination when full page is received" do
          expect(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: page_size)

          syncer.call
        end
      end

      context "when fewer than PAGE_SIZE records are returned" do
        let(:partial_page_records) { sample_records }
        let(:partial_page_response) do
          instance_double(Faraday::Response, body: { "results" => partial_page_records })
        end

        before do
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_return(partial_page_response)
        end

        it "stops pagination when partial page is received" do
          expect(api_client).not_to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: page_size)

          syncer.call
        end
      end
    end

    context "error handling" do
      let(:api_client) do
        client = double("VancouverApiClient")
        allow(client).to receive(:is_a?).with(External::VancouverCity::VancouverApiClient).and_return(true)
        client
      end

      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
        allow(logger).to receive(:info)
      end

      context "when VancouverApiError is raised" do
        let(:api_error) do
          External::VancouverCity::VancouverApiError.new("API rate limit exceeded", 429, "Rate limit")
        end

        before do
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_raise(api_error)
        end

        it "handles API error and returns failure result" do
          result = syncer.call

          expect(result.success?).to be false
          expect(result.errors).to include("API request failed: API rate limit exceeded")
          expect(result.data[:facilities]).to be_empty
          expect(result.data[:total_count]).to eq(0)
        end
      end

      context "when StandardError is raised" do
        before do
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_raise(StandardError.new("Unexpected network error"))
        end

        it "handles unexpected error and returns failure result" do
          result = syncer.call

          expect(result.success?).to be false
          expect(result.errors).to include("Unexpected error during sync: Unexpected network error")
          expect(result.data[:facilities]).to be_empty
          expect(result.data[:total_count]).to eq(0)
        end
      end

      context "when FacilitySyncer fails for some records" do
        let(:sample_facility) { instance_double(Facility) }
        let(:syncer_result) do
          ApplicationService::Result.new(
            data: { facility: sample_facility },
            errors: []
          )
        end
        let(:failed_syncer_result) do
          ApplicationService::Result.new(
            data: nil,
            errors: ["Invalid facility data"]
          )
        end

        let(:mixed_records) do
          [
            { "name" => "Valid Facility", "lat" => 49.2827, "long" => -123.1207 },
            { "name" => "Invalid Facility" }
          ]
        end

        let(:response) do
          instance_double(Faraday::Response, body: { "results" => mixed_records })
        end

        before do
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_return(response)

          allow(External::VancouverCity::FacilitySyncer).to receive(:call)
            .with(record: mixed_records[0], api_key: api_key)
            .and_return(syncer_result)

          allow(External::VancouverCity::FacilitySyncer).to receive(:call)
            .with(record: mixed_records[1], api_key: api_key)
            .and_return(failed_syncer_result)
        end

        it "processes successful records and includes errors for failed ones" do
          result = syncer.call

          expect(result.success?).to be false # Failure because some records failed
          expect(result.data[:facilities]).to contain_exactly(sample_facility)
          expect(result.data[:total_count]).to eq(1)
          expect(result.errors).to include("Invalid facility data")
        end
      end
    end

    context "logging behavior" do
      let(:sample_records) { [{ "name" => "Test Fountain" }] }
      let(:response) do
        instance_double(Faraday::Response, body: { "results" => sample_records })
      end
      let(:sample_facility) { instance_double(Facility) }
      let(:syncer_result) do
        ApplicationService::Result.new(
          data: { facility: sample_facility },
          errors: []
        )
      end

      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
        allow(api_client).to receive(:get_dataset_records)
          .with(api_key, limit: page_size, offset: 0)
          .and_return(response)
        allow(External::VancouverCity::FacilitySyncer).to receive(:call).and_return(syncer_result)
      end

      it "logs fetch progress with correct offset and limit" do
        expect(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
        expect(logger).to receive(:info).with("Successfully processed 1 facilities from #{api_key} API")

        syncer.call
      end

      it "logs final processing summary" do
        expect(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
        expect(logger).to receive(:info).with(/Successfully processed \d+ facilities from #{api_key} API/)

        syncer.call
      end
    end

    context "result structure" do
      let(:sample_records) { [{ "name" => "Test Fountain" }] }
      let(:response) do
        instance_double(Faraday::Response, body: { "results" => sample_records })
      end
      let(:sample_facility) { instance_double(Facility) }
      let(:syncer_result) do
        ApplicationService::Result.new(
          data: { facility: sample_facility },
          errors: []
        )
      end

      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
        allow(api_client).to receive(:get_dataset_records)
          .with(api_key, limit: page_size, offset: 0)
          .and_return(response)
        allow(External::VancouverCity::FacilitySyncer).to receive(:call).and_return(syncer_result)
        allow(logger).to receive(:info)
      end

      it "returns properly structured result data" do
        result = syncer.call

        expect(result.data).to be_a(Hash)
        expect(result.data).to have_key(:facilities)
        expect(result.data).to have_key(:total_count)
        expect(result.data).to have_key(:api_key)
        expect(result.data[:facilities]).to be_an(Array)
        expect(result.data[:total_count]).to be_an(Integer)
        expect(result.data[:api_key]).to eq(api_key)
      end
    end
  end

  describe "private methods" do
    describe "#process_records" do
      let(:sample_records) { [{ "name" => "Test Fountain" }] }
      let(:syncer) { described_class.new(api_key: api_key, api_client: api_client) }
      let(:sample_facility) { instance_double(Facility) }
      let(:syncer_result) do
        ApplicationService::Result.new(
          data: { facility: sample_facility },
          errors: []
        )
      end

      before do
        allow(External::VancouverCity::FacilitySyncer).to receive(:call).and_return(syncer_result)
      end

      it "processes records and returns array of facilities" do
        # Use send to access private method
        facilities = syncer.send(:process_records, sample_records)

        expect(facilities).to be_an(Array)
        expect(facilities).to contain_exactly(sample_facility)
        expect(External::VancouverCity::FacilitySyncer).to have_received(:call)
          .with(record: sample_records[0], api_key: api_key)
      end

      it "handles multiple records" do
        multiple_records = sample_records * 3

        facilities = syncer.send(:process_records, multiple_records)

        expect(facilities.size).to eq(3)
        expect(facilities).to all(eq(sample_facility))
        expect(External::VancouverCity::FacilitySyncer).to have_received(:call).exactly(3).times
      end

      context "when some record processing fails" do
        let(:failed_result) do
          ApplicationService::Result.new(
            data: nil,
            errors: ["Processing failed"]
          )
        end

        before do
          allow(External::VancouverCity::FacilitySyncer).to receive(:call)
            .and_return(syncer_result, failed_result, syncer_result)
        end

        it "processes successful records and collects errors" do
          mixed_records = sample_records * 3

          facilities = syncer.send(:process_records, mixed_records)

          expect(facilities.size).to eq(2) # Only successful ones
          expect(syncer.send(:errors)).to include("Processing failed")
        end
      end
    end
  end
end
