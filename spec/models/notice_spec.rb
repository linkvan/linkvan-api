require "rails_helper"

RSpec.describe Notice, type: :model do
  subject(:notice) { build(:notice) }

  it { expect(notice).to be_valid }

  describe "validations" do
    it { expect(notice).to validate_presence_of(:title) }
    it { expect(notice).to validate_presence_of(:content) }
  end

  describe "associations" do
    it { expect(notice).to have_rich_text(:content) }
  end

  describe "notice_type enum" do
    it "defines notice_type as a string enum" do
      notice = create(:notice, notice_type: "covid19")
      expect(notice.covid19?).to be true
      expect(notice.general?).to be false

      notice.update!(notice_type: "warming_center")
      expect(notice.warming_center?).to be true
    end

    it "has all expected types" do
      expected_types = {
        "general" => "general",
        "covid19" => "covid19",
        "warming_center" => "warming_center",
        "cooling_center" => "cooling_center",
        "water_fountain" => "water_fountain"
      }
      expect(described_class.notice_types).to eq(expected_types)
    end
  end

  describe "scopes" do
    describe ".published" do
      subject(:published_notices) { described_class.published }

      let(:published_notice) { create(:notice, :published) }
      let(:draft_notice) { create(:notice, :draft) }

      it { expect(published_notices).to include(published_notice) }
      it { expect(published_notices).not_to include(draft_notice) }
    end

    describe ".draft" do
      subject(:draft_notices) { described_class.draft }

      let(:published_notice) { create(:notice, :published) }
      let(:draft_notice) { create(:notice, :draft) }

      it { expect(draft_notices).not_to include(published_notice) }
      it { expect(draft_notices).to include(draft_notice) }
    end
  end

  describe "#content_html" do
    let(:notice) { create(:notice) }

    it "returns string representation of content" do
      expect(notice.content_html).to be_a(String)
    end
  end

  describe "#set_slug callback" do
    let(:notice) { build(:notice, title: "Test Notice Title") }

    before { notice.valid? }

    it "generates slug from title" do
      expect(notice.slug).to eq("test-notice-title")
    end

    context "with special characters" do
      let(:notice) { build(:notice, title: "Test @ Notice! #123") }

      before { notice.valid? }

      it "handles special characters" do
        expect(notice.slug).to eq("test-notice-123")
      end
    end
  end

  describe ".notice_types_for_display" do
    it "returns hash with notice types and their titleized names" do
      result = described_class.notice_types_for_display

      expect(result).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(result[:general]).to eq("General")
      expect(result[:covid19]).to eq("Covid19")
      expect(result[:warming_center]).to eq("Warming Center")
      expect(result[:cooling_center]).to eq("Cooling Center")
      expect(result[:water_fountain]).to eq("Water Fountain")
    end
  end

  describe "slug uniqueness" do
    it "validates slug is unique" do
      existing = create(:notice, title: "Existing Notice")
      duplicate = described_class.new(title: "Duplicate Title")
      duplicate.valid?
      expect(duplicate.errors[:slug]).to include("has already been taken") if existing.slug == duplicate.slug
    end
  end
end
