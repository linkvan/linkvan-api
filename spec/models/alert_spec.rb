require "rails_helper"

RSpec.describe Alert, type: :model do
  subject(:alert) { build(:alert) }

  it { expect(alert).to be_valid }

  describe "validations" do
    it { expect(alert).to validate_presence_of(:title) }
    it { expect(alert).to validate_presence_of(:content) }
  end

  describe "associations" do
    it { expect(alert).to have_rich_text(:content) }
  end

  describe "scopes" do
    describe ".active" do
      subject(:active_alerts) { described_class.active }

      let(:active_alert) { create(:alert, :active) }
      let(:inactive_alert) { create(:alert, :inactive) }

      it { expect(active_alerts).to include(active_alert) }
      it { expect(active_alerts).not_to include(inactive_alert) }
    end

    describe ".inactive" do
      subject(:inactive_alerts) { described_class.inactive }

      let(:active_alert) { create(:alert, :active) }
      let(:inactive_alert) { create(:alert, :inactive) }

      it { expect(inactive_alerts).not_to include(active_alert) }
      it { expect(inactive_alerts).to include(inactive_alert) }
    end
  end

  describe "#content_html" do
    let(:alert) { create(:alert) }

    it "returns string representation of content" do
      expect(alert.content_html).to be_a(String)
    end
  end
end
