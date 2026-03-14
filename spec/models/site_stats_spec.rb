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
      # rubocop:disable Rails/SkipsModelValidations -- Skipping validations in test setup for controlled timestamp manipulation
      let!(:first_facility) { create(:facility).tap { |f| f.update_columns(updated_at: 1.day.ago) } }
      let!(:second_facility) { create(:facility).tap { |f| f.update_columns(updated_at: 2.days.ago) } }
      let!(:third_facility) { create(:facility).tap { |f| f.update_columns(updated_at: 3.days.ago) } }
      # rubocop:enable Rails/SkipsModelValidations

      it "returns facilities ordered by updated_at descending" do
        expect(described_class.facilities).to eq([first_facility, second_facility, third_facility])
      end
    end

    describe ".notices" do
      # rubocop:disable Rails/SkipsModelValidations -- Skipping validations in test setup for controlled timestamp manipulation
      let!(:first_notice) { create(:notice).tap { |n| n.update_columns(updated_at: 1.day.ago) } }
      let!(:second_notice) { create(:notice).tap { |n| n.update_columns(updated_at: 2.days.ago) } }
      let!(:third_notice) { create(:notice).tap { |n| n.update_columns(updated_at: 3.days.ago) } }
      # rubocop:enable Rails/SkipsModelValidations

      it "returns notices ordered by updated_at descending" do
        expect(described_class.notices).to eq([first_notice, second_notice, third_notice])
      end
    end
  end

  describe "compute_last_updated" do
    let(:last_updated_time) { Time.current }

    context "when both facilities and notices exist" do
      let(:last_facility) { instance_double(Facility, updated_at: last_updated_time - 1.hour) }
      let(:last_notice) { instance_double(Notice, updated_at: last_updated_time) }

      before do
        allow(described_class).to receive_messages(last_facility: last_facility, last_notice: last_notice)
      end

      it "returns the most recent updated_at" do
        expect(described_class.send(:compute_last_updated)).to eq(last_updated_time)
      end
    end

    context "when only facilities exist" do
      let(:last_facility) { instance_double(Facility, updated_at: last_updated_time) }

      before do
        allow(described_class).to receive_messages(last_facility: last_facility, last_notice: nil)
      end

      it "returns the facility's updated_at" do
        expect(described_class.send(:compute_last_updated)).to eq(last_updated_time)
      end
    end

    context "when only notices exist" do
      let(:last_notice) { instance_double(Notice, updated_at: last_updated_time) }

      before do
        allow(described_class).to receive_messages(last_facility: nil, last_notice: last_notice)
      end

      it "returns the notice's updated_at" do
        expect(described_class.send(:compute_last_updated)).to eq(last_updated_time)
      end
    end

    context "when neither facilities nor notices exist" do
      before do
        allow(described_class).to receive_messages(last_facility: nil, last_notice: nil)
      end

      it "returns nil" do
        expect(described_class.send(:compute_last_updated)).to be_nil
      end
    end

    context "with multiple facilities and notices" do
      # rubocop:disable Rails/SkipsModelValidations -- Skipping validations in test setup for controlled timestamp manipulation
      let!(:first_facility) { create(:facility).tap { |f| f.update_columns(updated_at: 1.day.ago) } }
      # rubocop:enable Rails/SkipsModelValidations

      it "returns the most recent updated_at from all records" do
        computed_time = described_class.send(:compute_last_updated)
        expect(computed_time).to be_within(1.second).of(first_facility.updated_at)
      end
    end

    context "with future dates" do
      let(:future_time) { 1.day.from_now }

      before do
        # rubocop:disable Rails/SkipsModelValidations -- Skipping validations in test setup for controlled timestamp manipulation
        create(:facility).tap { |f| f.update_columns(updated_at: future_time) }
        # rubocop:enable Rails/SkipsModelValidations
      end

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
      # rubocop:disable Rails/SkipsModelValidations -- Skipping validations in test setup for controlled timestamp manipulation
      let!(:facility) { create(:facility).tap { |f| f.update_columns(updated_at: 1.hour.ago) } }
      # rubocop:enable Rails/SkipsModelValidations
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
