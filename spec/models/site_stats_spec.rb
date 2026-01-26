require "rails_helper"

RSpec.describe SiteStats, type: :model do
  describe "ActiveModel inclusion" do
    it "includes ActiveModel::Attributes" do
      expect(described_class.ancestors).to include(ActiveModel::Attributes)
    end

    it "includes ActiveModel::Serialization" do
      expect(described_class.ancestors).to include(ActiveModel::Serialization)
    end

    it "includes ActiveModel::Serializers::JSON" do
      expect(described_class.ancestors).to include(ActiveModel::Serializers::JSON)
    end
  end

  describe "attributes" do
    subject(:site_stats) { described_class.new }

    it "has last_updated attribute" do
      expect(site_stats).to respond_to(:last_updated)
      expect(site_stats.last_updated).to be_nil.or be_a(DateTime)
    end

    it "defaults last_updated to compute_last_updated result" do
      expect(site_stats.last_updated).to eq(described_class.send(:compute_last_updated))
    end
  end

  describe "class methods" do
    describe ".facilities" do
      let!(:facility1) { create(:facility).tap { |f| f.update_columns(updated_at: 1.day.ago) } }
      let!(:facility2) { create(:facility).tap { |f| f.update_columns(updated_at: 2.days.ago) } }
      let!(:facility3) { create(:facility).tap { |f| f.update_columns(updated_at: 3.days.ago) } }

      it "returns facilities ordered by updated_at descending" do
        expect(described_class.facilities).to eq([facility1, facility2, facility3])
      end
    end

    describe ".notices" do
      let!(:notice1) { create(:notice).tap { |n| n.update_columns(updated_at: 1.day.ago) } }
      let!(:notice2) { create(:notice).tap { |n| n.update_columns(updated_at: 2.days.ago) } }
      let!(:notice3) { create(:notice).tap { |n| n.update_columns(updated_at: 3.days.ago) } }

      it "returns notices ordered by updated_at descending" do
        expect(described_class.notices).to eq([notice1, notice2, notice3])
      end
    end
  end

  describe "compute_last_updated" do
    let(:last_updated_time) { Time.current }

    context "when both facilities and notices exist" do
      let(:last_facility) { double(updated_at: last_updated_time - 1.hour) }
      let(:last_notice) { double(updated_at: last_updated_time) }

      before do
        allow(described_class).to receive(:last_facility).and_return(last_facility)
        allow(described_class).to receive(:last_notice).and_return(last_notice)
      end

      it "returns the most recent updated_at" do
        expect(described_class.send(:compute_last_updated)).to eq(last_updated_time)
      end
    end

    context "when only facilities exist" do
      let(:last_facility) { double(updated_at: last_updated_time) }

      before do
        allow(described_class).to receive(:last_facility).and_return(last_facility)
        allow(described_class).to receive(:last_notice).and_return(nil)
      end

      it "returns the facility's updated_at" do
        expect(described_class.send(:compute_last_updated)).to eq(last_updated_time)
      end
    end

    context "when only notices exist" do
      let(:last_notice) { double(updated_at: last_updated_time) }

      before do
        allow(described_class).to receive(:last_facility).and_return(nil)
        allow(described_class).to receive(:last_notice).and_return(last_notice)
      end

      it "returns the notice's updated_at" do
        expect(described_class.send(:compute_last_updated)).to eq(last_updated_time)
      end
    end

    context "when neither facilities nor notices exist" do
      before do
        allow(described_class).to receive(:last_facility).and_return(nil)
        allow(described_class).to receive(:last_notice).and_return(nil)
      end

      it "returns nil" do
        expect(described_class.send(:compute_last_updated)).to be_nil
      end
    end

    context "with multiple facilities and notices" do
      let!(:facility1) { create(:facility).tap { |f| f.update_columns(updated_at: 1.day.ago) } }
      let!(:facility2) { create(:facility).tap { |f| f.update_columns(updated_at: 2.days.ago) } }
      let!(:notice1) { create(:notice).tap { |n| n.update_columns(updated_at: 3.days.ago) } }
      let!(:notice2) { create(:notice).tap { |n| n.update_columns(updated_at: 4.days.ago) } }

      it "returns the most recent updated_at from all records" do
        computed_time = described_class.send(:compute_last_updated)
        expect(computed_time).to be_within(1.second).of(facility1.updated_at)
      end
    end

    context "with future dates" do
      let(:future_time) { 1.day.from_now }
      let!(:facility) { create(:facility).tap { |f| f.update_columns(updated_at: future_time) } }
      let!(:notice) { create(:notice).tap { |n| n.update_columns(updated_at: 2.days.ago) } }

      it "includes future dates in computation" do
        computed_time = described_class.send(:compute_last_updated)
        expect(computed_time).to be_within(1.second).of(future_time)
      end
    end
  end

  describe "serialization" do
    let(:site_stats) { described_class.new }
    let(:json_output) { site_stats.as_json }

    it "serializes to JSON" do
      expect(json_output).to be_a(Hash)
      expect(json_output).to have_key("last_updated")
    end

    it "includes last_updated in JSON" do
      expect(json_output["last_updated"]).to be_nil
    end

    it "has only last_updated attribute in JSON" do
      expect(json_output.keys).to eq(["last_updated"])
    end
  end

  describe "integration with real data" do
    context "with populated database" do
      let!(:facility) { create(:facility).tap { |f| f.update_columns(updated_at: 1.hour.ago) } }
      let!(:notice) { create(:notice).tap { |n| n.update_columns(updated_at: 2.hours.ago) } }
      let(:site_stats) { described_class.new }

      it "computes last_updated correctly" do
        expect(site_stats.last_updated).to be_within(1.second).of(facility.updated_at)
      end

      it "serializes correctly" do
        json = site_stats.as_json
        expect(json["last_updated"]).to eq(facility.updated_at.as_json)
      end
    end

    context "with empty database" do
      let(:site_stats) { described_class.new }

      before do
        Facility.delete_all
        Notice.delete_all
      end

      it "handles empty data gracefully" do
        expect(site_stats.last_updated).to be_nil
      end

      it "serializes nil last_updated" do
        json = site_stats.as_json
        expect(json["last_updated"]).to be_nil
      end
    end
  end
end
