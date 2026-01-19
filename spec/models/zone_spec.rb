require "rails_helper"

RSpec.describe Zone, type: :model do
  subject(:zone) { build(:zone) }

  it { expect(zone).to be_valid }

  describe "validations" do
    it { expect(zone).to validate_presence_of(:name) }
    it { expect(zone).to validate_presence_of(:description) }
    it { expect(zone).to validate_uniqueness_of(:name).case_insensitive }
    it { expect(zone).to validate_length_of(:name).is_at_most(50) }
  end

  describe "associations" do
    it { expect(zone).to have_many(:facilities).dependent(:nullify) }
    it { expect(zone).to have_and_belong_to_many(:users) }
  end

  describe "cascade behavior" do
    it "nullifies facility zone on zone deletion" do
      zone = create(:zone)
      facility = create(:facility, zone: zone)
      zone.destroy
      expect(facility.reload.zone_id).to be_nil
    end

    it "removes user associations on zone deletion" do
      zone = create(:zone)
      user = create(:user)
      zone.users << user
      zone.destroy
      expect(user.reload.zones).not_to include(zone)
    end
  end

  describe "with factories" do
    describe ":zone_with_facilities" do
      let(:zone) { create(:zone_with_facilities, facilities_count: 3) }

      it "creates zone with facilities" do
        expect(zone.facilities.count).to eq(3)
        expect(zone.facilities.first.zone).to eq(zone)
      end
    end

    describe ":zone_with_users" do
      let(:zone) { create(:zone_with_users, users_count: 2) }

      it "creates zone with users" do
        expect(zone.users.count).to eq(2)
        expect(zone.users.first.zones).to include(zone)
      end
    end
  end
end
