require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { expect(user).to be_valid }

  describe "validations" do
    it { expect(build(:user)).to validate_presence_of(:name) }
    it { expect(build(:user)).to validate_presence_of(:email) }
    it { expect(build(:user)).to allow_value("user@example.com").for(:email) }
    it { expect(build(:user)).not_to allow_value("invalid").for(:email) }
    it { expect(build(:user)).to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "devise modules" do
    it { expect(user).to respond_to(:password) }
    it { expect(user).to respond_to(:password_confirmation) }
  end

  describe "associations" do
    it { expect(user).to have_many(:facilities).dependent(:nullify) }
    it { expect(user).to have_and_belong_to_many(:zones) }
  end

  describe "scopes" do
    describe ".verified" do
      subject { described_class.verified }

      let(:verified_user) { create(:user, :verified) }
      let(:unverified_user) { create(:user, :not_verified) }

      it { expect(subject).to include(verified_user) }
      it { expect(subject).not_to include(unverified_user) }
    end

    describe ".not_verified" do
      subject { described_class.not_verified }

      let(:verified_user) { create(:user, :verified) }
      let(:unverified_user) { create(:user, :not_verified) }

      it { expect(subject).not_to include(verified_user) }
      it { expect(subject).to include(unverified_user) }
    end

    describe ".super_admins" do
      subject { described_class.super_admins }

      let(:super_admin) { create(:user, :admin, :verified) }
      let(:regular_admin) { create(:user, :admin, :not_verified) }
      let(:regular_user) { create(:user, :verified) }

      it { expect(subject).to include(super_admin) }
      it { expect(subject).not_to include(regular_admin) }
      it { expect(subject).not_to include(regular_user) }
    end
  end

  describe "#manages" do
    context "when super_admin" do
      let(:super_admin) { create(:user, :admin, :verified) }
      let(:first_facility) { create(:facility) }
      let(:second_facility) { create(:facility) }

      it { expect(super_admin.manages).to include(first_facility) }
      it { expect(super_admin.manages).to include(second_facility) }
      it { expect(super_admin.manages.count).to eq(Facility.count) }
    end

    context "when zone_admin" do
      let(:zone) { create(:zone) }
      let(:zone_admin) { create(:user, :verified) }
      let(:facility_in_zone) { create(:facility, zone: zone) }
      let(:facility_outside_zone) { create(:facility) }

      before do
        zone.users << zone_admin
      end

      it { expect(zone_admin.manages).to include(facility_in_zone) }
      it { expect(zone_admin.manages).not_to include(facility_outside_zone) }
    end

    context "when facility_admin" do
      let(:facility_admin) { create(:user, :verified) }
      let(:own_facility) { create(:facility, user: facility_admin) }
      let(:other_facility) { create(:facility) }

      it { expect(facility_admin.manages).to include(own_facility) }
      it { expect(facility_admin.manages).not_to include(other_facility) }
    end
  end

  describe "#manageable_users" do
    context "when super_admin" do
      let(:super_admin) { create(:user, :admin, :verified) }
      let(:first_user) { create(:user) }
      let(:second_user) { create(:user) }

      it "returns all users" do
        expect(super_admin.manageable_users).to include(first_user)
        expect(super_admin.manageable_users).to include(second_user)
        expect(super_admin.manageable_users).to include(super_admin)
      end
    end

    context "when regular user" do
      let(:regular_user) { create(:user) }

      it { expect(regular_user.manageable_users).to eq(regular_user) }
    end
  end

  describe "#can_manage?" do
    context "when super_admin" do
      let(:super_admin) { create(:user, :admin, :verified) }
      let(:other_user) { create(:user) }

      it { expect(super_admin.can_manage?(other_user)).to be true }
    end

    context "when zone_admin trying to manage themselves" do
      let(:zone) { create(:zone) }
      let(:zone_admin) { create(:user, :verified) }

      before do
        zone.users << zone_admin
      end

      it { expect(zone_admin.can_manage?(zone_admin)).to be false }
    end
  end

  describe "#super_admin?" do
    context "when admin and verified" do
      let(:super_admin) { create(:user, :admin, :verified) }

      it { expect(super_admin.super_admin?).to be true }
    end

    context "when admin but not verified" do
      let(:admin_user) { create(:user, :admin, :not_verified) }

      it { expect(admin_user.super_admin?).to be false }
    end

    context "when verified but not admin" do
      let(:verified_user) { create(:user, :verified) }

      it { expect(verified_user.super_admin?).to be false }
    end
  end

  describe "#zone_admin?" do
    context "when user has zones and is verified" do
      let(:zone) { create(:zone) }
      let(:zone_admin) { create(:user, :verified) }

      before do
        zone.users << zone_admin
      end

      it { expect(zone_admin.zone_admin?).to be true }
    end

    context "when user has zones but not verified" do
      let(:zone) { create(:zone) }
      let(:unverified_user) { create(:user, :not_verified) }

      before do
        zone.users << unverified_user
      end

      it { expect(unverified_user.zone_admin?).to be false }
    end

    context "when user is verified but has no zones" do
      let(:verified_user) { create(:user, :verified) }

      it { expect(verified_user.zone_admin?).to be false }
    end
  end

  describe "#facility_admin?" do
    context "when user has facilities and is verified" do
      let(:facility_admin) { create(:user, :verified) }
      let(:facility) { create(:facility, user: facility_admin) }

      before do
        facility
        facility_admin.reload
      end

      it { expect(facility_admin.facility_admin?).to be true }
    end

    context "when user has facilities but not verified" do
      let(:unverified_user) { create(:user, :not_verified) }
      let(:facility) { create(:facility, user: unverified_user) }

      before do
        facility
        unverified_user.reload
      end

      it { expect(unverified_user.facility_admin?).to be false }
    end

    context "when user is verified but has no facilities" do
      let(:verified_user) { create(:user, :verified) }

      it { expect(verified_user.facility_admin?).to be false }
    end
  end

  describe "#toggle_verified!" do
    let(:user) { create(:user, :verified) }

    it { expect { user.toggle_verified! }.to change(user, :verified).to(false) }

    context "when toggling back" do
      before { user.toggle_verified! }

      it { expect { user.toggle_verified! }.to change(user, :verified).to(true) }
    end
  end
end
