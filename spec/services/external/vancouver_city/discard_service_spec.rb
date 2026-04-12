# frozen_string_literal: true

require "rails_helper"

RSpec.describe External::VancouverCity::DiscardService, type: :service do
  describe ".call" do
    let(:api_key) { "drinking-fountains" }
    let(:api_client) { External::VancouverCity.default_client }

    context "with valid api_key" do
      let(:drinking_fountains_key) { "drinking-fountains" }
      let(:internal_facility) { create(:facility, :with_verified, external_id: nil, name: "Internal Fountain") }
      let(:public_washrooms_key) { "public-washrooms" }

      before do
        create(:facility, :with_verified, external_id: "FOO123", name: "Fountain 1")
        create(:facility, :with_verified, external_id: "BAR456", name: "Fountain 2")
      end

      it "discards all external facilities for the api_key" do
        result = described_class.call(api_key: api_key)

        expect(result.success?).to be true
        expect(Facility.external.kept.count).to eq(0)
      end

      it "discards facilities with sync_removed reason" do
        result = described_class.call(api_key: api_key)

        expect(result.success?).to be true
        foo = Facility.external.with_discarded.find_by(external_id: "FOO123")
        expect(foo).to be_discarded
        expect(foo.discard_reason).to eq("sync_removed")
        bar = Facility.external.with_discarded.find_by(external_id: "BAR456")
        expect(bar).to be_discarded
        expect(bar.discard_reason).to eq("sync_removed")
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
      before { create(:facility, :with_verified, external_id: nil, name: "Internal Fountain") }

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
      let(:drinking_fountains_key) { "drinking-fountains" }
      let(:facility2) do
        create(:facility, :with_verified, external_id: "BAR456", name: "Fountain 2", discard_reason: :sync_removed)
      end
      let(:public_washrooms_key) { "public-washrooms" }

      before do
        create(:facility, :with_verified, external_id: "FOO123", name: "Fountain 1")
        facility2.discard!
      end

      it "only discards facilities that are not already discarded" do
        result = described_class.call(api_key: api_key)

        expect(result.success?).to be true
        expect(result.data[:discarded_count]).to eq(1)
        expect(Facility.external.with_discarded.find_by(external_id: "FOO123")).to be_discarded
        expect(facility2.reload).to be_discarded # Already was discarded
      end
    end
  end
end
