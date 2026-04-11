# frozen_string_literal: true

require "rails_helper"

RSpec.describe External::VancouverCity::PurgeService, type: :service do
  describe ".call" do
    let(:api_key) { "drinking-fountains" }
    let(:api_client) { External::VancouverCity.default_client }

    context "with valid api_key" do
      let!(:facility1) { create(:facility, :with_verified, external_id: "FOO123", name: "Fountain 1") }
      let!(:facility2) { create(:facility, :with_verified, external_id: "BAR456", name: "Fountain 2") }
      let!(:internal_facility) { create(:facility, :with_verified, external_id: nil, name: "Internal Fountain") }

      it "purges all external facilities for the api_key" do
        result = described_class.call(api_key: api_key)

        expect(result.success?).to be true
        expect(Facility.external.kept.count).to eq(0)
      end

      it "discards facilities with sync_removed reason" do
        result = described_class.call(api_key: api_key)

        expect(result.success?).to be true
        expect(facility1.reload).to be_discarded
        expect(facility1.discard_reason).to eq("sync_removed")
        expect(facility2.reload).to be_discarded
        expect(facility2.discard_reason).to eq("sync_removed")
      end

      it "does not affect internal facilities" do
        result = described_class.call(api_key: api_key)

        expect(result.success?).to be true
        expect(internal_facility.reload).not_to be_discarded
      end

      it "returns discarded_count" do
        result = described_class.call(api_key: api_key)

        expect(result.success?).to be true
        expect(result.data[:discarded_count]).to eq(2)
      end
    end

    context "with no external facilities" do
      let!(:internal_facility) { create(:facility, :with_verified, external_id: nil, name: "Internal Fountain") }

      it "returns success with zero discarded count" do
        result = described_class.call(api_key: api_key)

        expect(result.success?).to be true
        expect(result.data[:discarded_count]).to eq(0)
      end
    end

    context "with unsupported api_key" do
      it "returns failure result" do
        result = described_class.call(api_key: "unsupported-api")

        expect(result.success?).to be false
        expect(result.errors).to include("Unsupported API: unsupported-api")
      end
    end

    context "with facilities already discarded" do
      let!(:facility1) { create(:facility, :with_verified, external_id: "FOO123", name: "Fountain 1") }
      let!(:facility2) do
        create(:facility, :with_verified, external_id: "BAR456", name: "Fountain 2", discard_reason: :sync_removed)
      end

      before { facility2.discard! }

      it "only discards facilities that are not already discarded" do
        result = described_class.call(api_key: api_key)

        expect(result.success?).to be true
        expect(result.data[:discarded_count]).to eq(1)
        expect(facility1.reload).to be_discarded
        expect(facility2.reload).to be_discarded # Already was discarded
      end
    end
  end
end
