# frozen_string_literal: true

require "rails_helper"

RSpec.describe External::VancouverCity::Syncer, type: :service do
  subject(:syncer) { described_class.new(api_key: api_key, api_client: api_client) }

  let(:api_key) { "drinking-fountains" }
  let(:logger) { instance_double(ActiveSupport::Logger) }
  let(:api_client) do
    client = instance_double(External::VancouverCity::VancouverApiClient)
    allow(client).to receive(:is_a?).with(External::VancouverCity::VancouverApiClient).and_return(true)
    client
  end
  let(:page_size) { described_class::PAGE_SIZE }

  # Mock Rails.logger
  before do
    allow(Rails).to receive(:logger).and_return(logger)
  end

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

  describe "#initialize with full_sync option" do
    let(:syncer_with_full_sync) { described_class.new(api_key: api_key, api_client: api_client, full_sync: full_sync) }

    context "when full_sync is not specified" do
      it "defaults to full_sync: true" do
        syncer = described_class.new(api_key: api_key, api_client: api_client)
        expect(syncer.full_sync).to be true
      end
    end

    context "when full_sync is true" do
      let(:full_sync) { true }

      it "sets full_sync to true" do
        expect(syncer_with_full_sync.full_sync).to be true
      end
    end

    context "when full_sync is false" do
      let(:full_sync) { false }

      it "sets full_sync to false" do
        expect(syncer_with_full_sync.full_sync).to be false
      end
    end
  end

  describe "#validate" do
    context "with valid parameters" do
      it "returns no errors" do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)

        errors = syncer.validate

        expect(External::ApiHelper).to have_received(:supported_api?).with(api_key)
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
      let(:api_key) { "unsupported-api" }

      it "returns failure result with validation errors" do
        result = syncer.call
        expect(result.success?).to be false
        expect(result.errors).to include("Unsupported API: unsupported-api")
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
        client = instance_double(External::VancouverCity::VancouverApiClient)
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
          allow(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
          allow(logger).to receive(:info).with("Successfully processed 0 facilities from #{api_key} API")

          result = syncer.call

          expect(result.success?).to be true
          expect(result.data[:facilities]).to be_empty
          expect(result.data[:total_count]).to eq(0)
          expect(result.data[:api_key]).to eq(api_key)
          expect(logger).to have_received(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
          expect(logger).to have_received(:info).with("Successfully processed 0 facilities from #{api_key} API")
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
          allow(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
          allow(External::VancouverCity::FacilitySyncer).to receive(:call).twice.and_return(syncer_result)
          allow(logger).to receive(:info).with("Successfully processed 2 facilities from #{api_key} API")

          result = syncer.call

          expect(result.success?).to be true
          expect(result.data[:facilities]).to contain_exactly(sample_facility, sample_facility)
          expect(result.data[:total_count]).to eq(2)
          expect(result.data[:api_key]).to eq(api_key)
          expect(logger).to have_received(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
          expect(External::VancouverCity::FacilitySyncer).to have_received(:call).twice
          expect(logger).to have_received(:info).with("Successfully processed 2 facilities from #{api_key} API")
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
          allow(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
          allow(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: #{page_size}, limit: #{page_size})")
          allow(External::VancouverCity::FacilitySyncer).to receive(:call).exactly(page_size).times.and_return(syncer_result)
          allow(logger).to receive(:info).with("Successfully processed #{page_size} facilities from #{api_key} API")

          result = syncer.call

          expect(result.success?).to be true
          expect(result.data[:total_count]).to eq(page_size)
          expect(logger).to have_received(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
          expect(logger).to have_received(:info).with("Fetching facilities from #{api_key} API (offset: #{page_size}, limit: #{page_size})")
          expect(External::VancouverCity::FacilitySyncer).to have_received(:call).exactly(page_size).times
          expect(logger).to have_received(:info).with("Successfully processed #{page_size} facilities from #{api_key} API")
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
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: page_size)

          syncer.call

          expect(api_client).to have_received(:get_dataset_records)
            .with(api_key, limit: page_size, offset: page_size)
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
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: page_size)

          syncer.call

          expect(api_client).not_to have_received(:get_dataset_records)
            .with(api_key, limit: page_size, offset: page_size)
        end
      end
    end

    context "when error handling" do
      let(:api_client) do
        client = instance_double(External::VancouverCity::VancouverApiClient)
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

    context "with logging behavior" do
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
        allow(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
        allow(logger).to receive(:info).with("Successfully processed 1 facilities from #{api_key} API")

        syncer.call

        expect(logger).to have_received(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
        expect(logger).to have_received(:info).with("Successfully processed 1 facilities from #{api_key} API")
      end

      it "logs final processing summary" do
        allow(logger).to receive(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
        allow(logger).to receive(:info).with(/Successfully processed \d+ facilities from #{api_key} API/)

        syncer.call

        expect(logger).to have_received(:info).with("Fetching facilities from #{api_key} API (offset: 0, limit: #{page_size})")
        expect(logger).to have_received(:info).with(/Successfully processed \d+ facilities from #{api_key} API/)
      end
    end

    context "with result structure" do
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

    context "with full_sync: true (default)" do
      let(:sample_records) { [{ "mapid" => "FOO123", "name" => "Test Fountain" }] }
      let(:sample_facility) { create(:facility, :with_verified, external_id: "FOO123", name: "Test Fountain") }
      let(:response) do
        instance_double(Faraday::Response, body: { "results" => sample_records })
      end

      let(:syncer_result) do
        ApplicationService::Result.new(
          data: External::VancouverCity::FacilitySyncer::ResultData.new(
            operation: :create,
            facility: sample_facility
          ),
          errors: []
        )
      end

      let!(:existing_facility) do
        create(:facility, :with_verified, external_id: "EXISTING456", name: "Existing Fountain")
      end

      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
        allow(api_client).to receive(:get_dataset_records)
          .with(api_key, limit: page_size, offset: 0)
          .and_return(response)
        allow(External::VancouverCity::FacilitySyncer).to receive(:call).and_return(syncer_result)
        allow(logger).to receive(:info)
        allow(logger).to receive(:warn)
      end

      it "discards facilities not in the API response" do
        result = syncer.call

        expect(result.success?).to be true
        expect(existing_facility.reload).to be_discarded
        expect(existing_facility.discard_reason).to eq("sync_removed")
      end

      it "returns deleted_count in result" do
        result = syncer.call

        expect(result.data[:deleted_count]).to eq(1)
      end

      it "does not re-discard facilities that were previously sync_removed" do
        # Create a facility with external_id NOT in the API response (simulating previously removed)
        # The facility is actually discarded with discard_reason = sync_removed
        discarded_facility = create(:facility, :with_verified,
                                    external_id: "DISCARDED789",
                                    name: "Previously Discarded",
                                    discard_reason: :sync_removed)
        # Actually discard it (soft-delete) since that's what sync_removed means
        discarded_facility.discard!

        # Verify it's actually discarded
        expect(discarded_facility.reload).to be_discarded

        # Run the syncer - the DISCARDED789 facility should NOT be re-discarded
        # because it was already removed during a previous sync
        result = syncer.call

        expect(result.success?).to be true
        # The facility should remain discarded (not re-discarded)
        expect(discarded_facility.reload).to be_discarded
      end
    end

    context "with full_sync: false" do
      let(:sample_records) { [{ "mapid" => "FOO123", "name" => "Test Fountain" }] }
      let(:sample_facility) { create(:facility, :with_verified, external_id: "FOO123", name: "Test Fountain") }
      let(:response) do
        instance_double(Faraday::Response, body: { "results" => sample_records })
      end

      let(:syncer) { described_class.new(api_key: api_key, api_client: api_client, full_sync: false) }

      let(:syncer_result) do
        ApplicationService::Result.new(
          data: External::VancouverCity::FacilitySyncer::ResultData.new(
            operation: :create,
            facility: sample_facility
          ),
          errors: []
        )
      end

      let!(:orphan_facility) do
        create(:facility, :with_verified, external_id: "ORPHAN456", name: "Orphan Fountain")
      end

      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
        allow(api_client).to receive(:get_dataset_records)
          .with(api_key, limit: page_size, offset: 0)
          .and_return(response)
        allow(External::VancouverCity::FacilitySyncer).to receive(:call).and_return(syncer_result)
        allow(logger).to receive(:info)
      end

      it "does not discard orphan facilities" do
        result = syncer.call

        expect(result.success?).to be true
        expect(orphan_facility.reload).not_to be_discarded
      end

      it "returns deleted_count of 0" do
        result = syncer.call

        expect(result.data[:deleted_count]).to eq(0)
      end
    end

    context "with operation counts in result" do
      let(:sample_records) { [{ "mapid" => "NEW123", "name" => "New Fountain" }] }
      let(:response) do
        instance_double(Faraday::Response, body: { "results" => sample_records })
      end

      let(:created_facility) { create(:facility, :with_verified, external_id: "NEW123", name: "New Fountain") }
      let(:updated_facility) { create(:facility, :with_verified, external_id: "OLD123", name: "Old Fountain") }

      let(:create_result) do
        ApplicationService::Result.new(
          data: External::VancouverCity::FacilitySyncer::ResultData.new(
            operation: :create,
            facility: created_facility
          ),
          errors: []
        )
      end

      let(:update_result) do
        ApplicationService::Result.new(
          data: External::VancouverCity::FacilitySyncer::ResultData.new(
            operation: :external_update,
            facility: updated_facility
          ),
          errors: []
        )
      end

      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
        allow(api_client).to receive(:get_dataset_records)
          .with(api_key, limit: page_size, offset: 0)
          .and_return(response)
        allow(External::VancouverCity::FacilitySyncer).to receive(:call)
          .and_return(create_result)
        allow(logger).to receive(:info)
      end

      it "returns created_count, updated_count, and deleted_count" do
        result = syncer.call

        expect(result.data[:created_count]).to be_an(Integer)
        expect(result.data[:updated_count]).to be_an(Integer)
        expect(result.data[:deleted_count]).to be_an(Integer)
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
