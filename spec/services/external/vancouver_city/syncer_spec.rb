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
      end
    end

    context "when validation succeeds" do
      before do
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
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

        it "returns empty result" do
          result = syncer.call

          expect(result.success?).to be true
          expect(result.data).to be_empty
        end
      end

      context "with single page of results" do
        let(:geom) { { geometry: { coordinates: [-123.1207, 49.2827] } } }
        let(:sample_records) do
          [
            { "name" => "Fountain 1", "mapid" => "FOO123", "geom" => geom },
            { "name" => "Fountain 2", "mapid" => "FOO456", "geom" => geom }
          ]
        end

        before do
          response = instance_double(Faraday::Response, body: { "results" => sample_records })
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_return(response)
        end

        it "processes records and creates facilities in database" do
          expect do
            result = syncer.call

            expect(result).to be_success
            expect(result.error_messages).to be_empty
            expect(result.data.count).to eq(2)
          end.to change(Facility, :count).by(2)
        end
      end

      context "with multiple pages of results" do
        let(:geom) { { geometry: { coordinates: [-123.1207, 49.2827] } } }
        let(:full_page_records) { Array.new(page_size) { |i| { "name" => "Fountain #{i}", "mapid" => "ID#{i}", "geom" => geom } } }

        before do
          first_response = instance_double(Faraday::Response, body: { "results" => full_page_records })
          second_response = instance_double(Faraday::Response, body: { "results" => [] })

          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_return(first_response)

          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: page_size)
            .and_return(second_response)
        end

        it "fetches all pages and processes all records" do
          expect do
            result = syncer.call

            expect(result.success?).to be true
            expect(result.error_messages).to be_empty
            # expect(Facility.where(external_id: external_ids).count).to eq(page_size)
          end.to change(Facility, :count).by(page_size)
        end
      end

      context "when exactly PAGE_SIZE records are returned" do
        let(:full_page_records) { Array.new(page_size) { |i| { "name" => "Fountain #{i}", "mapid" => "ID#{i}" } } }

        before do
          full_page_response = instance_double(Faraday::Response, body: { "results" => full_page_records })
          empty_response = instance_double(Faraday::Response, body: { "results" => [] })

          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_return(full_page_response)

          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: page_size)
            .and_return(empty_response)
        end

        it "continues pagination when full page is received" do
          syncer.call

          expect(api_client).to have_received(:get_dataset_records)
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
          result_facilities = result.data.map(&:facility).compact
          error_messages = result.error_messages

          expect(result.partial_failed?).to be true
          expect(result.success?).to be true
          expect(error_messages).to include(/API request failed: API rate limit exceeded/)
          expect(result_facilities).to be_empty
        end
      end

      context "when StandardError is raised" do
        before do
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_raise(StandardError.new("Unexpected network error"))
        end

        it "handles unexpected error and partially fails" do
          result = syncer.call
          result_facilities = result.data.map(&:facility).compact
          error_messages = result.error_messages

          expect(result.partial_failed?).to be true
          expect(result.success?).to be true
          expect(result.errors).to be_empty
          expect(error_messages).to include(/Unexpected error during sync/)
          expect(error_messages).to include(/StandardError: Unexpected network error/)
          expect(result_facilities).to be_empty
        end
      end

      context "when some records have invalid data" do
        let(:mixed_records) do
          [
            { "name" => "Valid Facility", "lat" => 49.2827, "long" => -123.1207, "mapid" => "VALID123" },
            { "name" => "Invalid Facility" }
          ]
        end

        before do
          allow(logger).to receive(:warn)
          response = instance_double(Faraday::Response, body: { "results" => mixed_records })
          allow(api_client).to receive(:get_dataset_records)
            .with(api_key, limit: page_size, offset: 0)
            .and_return(response)
        end

        it "returns partial success with error entries" do
          result = syncer.call
          result.data.map(&:facility).compact
          error_messages = result.error_messages

          expect(result.partial_failed?).to be true
          expect(result.success?).to be true
          expect(result.data.size).to eq(2)
          expect(error_messages).not_to be_empty
        end
      end
    end

    context "with full_sync: true (default)" do
      let(:sample_records) { [{ "mapid" => "FOO123", "name" => "Test Fountain" }] }

      let(:existing_facility) do
        create(:facility, :with_verified, external_id: "EXISTING456", name: "Existing Fountain")
      end

      before do
        response = instance_double(Faraday::Response, body: { "results" => sample_records })
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
        allow(api_client).to receive(:get_dataset_records)
          .with(api_key, limit: page_size, offset: 0)
          .and_return(response)
        allow(logger).to receive(:info)
        allow(logger).to receive(:warn)
      end

      it "discards facilities not in the API response" do
        expect do
          result = syncer.call

          expect(result.success?).to be true
          expect(existing_facility.reload).to be_discarded
          expect(existing_facility.discard_reason).to eq("sync_removed")
        end.to change(existing_facility, :discarded?).from(false).to(true)
      end

      it "returns discard entries in result data" do
        result = syncer.call

        discard_entries = result.data.map { |entry| entry.operation == External::SyncOperations.discard }
        expect(discard_entries.size).to eq(1)
      end

      it "does not re-discard facilities that were previously sync_removed" do
        discarded_facility = create(:facility, :with_verified,
                                    external_id: "DISCARDED789",
                                    name: "Previously Discarded",
                                    discard_reason: :sync_removed)
        discarded_facility.discard!

        expect(discarded_facility.reload).to be_discarded

        result = syncer.call

        expect(result.success?).to be true
        expect(discarded_facility.reload).to be_discarded
      end
    end

    context "with full_sync: false" do
      let(:sample_records) { [{ "mapid" => "FOO123", "name" => "Test Fountain" }] }

      let(:syncer) { described_class.new(api_key: api_key, api_client: api_client, full_sync: false) }

      let!(:orphan_facility) do
        create(:facility, :with_verified, external_id: "ORPHAN456", name: "Orphan Fountain")
      end

      before do
        allow(logger).to receive(:warn)
        response = instance_double(Faraday::Response, body: { "results" => sample_records })
        allow(External::ApiHelper).to receive(:supported_api?).with(api_key).and_return(true)
        allow(api_client).to receive(:get_dataset_records)
          .with(api_key, limit: page_size, offset: 0)
          .and_return(response)
        allow(logger).to receive(:info)
      end

      it "does not discard orphan facilities" do
        result = syncer.call

        expect(result.success?).to be true
        expect(orphan_facility.reload).not_to be_discarded
      end

      it "returns no discard entries in result data" do
        result = syncer.call

        discard_entries = result.data.select { |entry| entry.operation == External::SyncOperations.discard }
        expect(discard_entries.size).to eq(0)
      end
    end
  end
end
