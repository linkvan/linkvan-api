require "rails_helper"
require "support/shared_examples/discardable"

RSpec.describe Facility, type: :model do
  subject(:facility) { build(:facility) }

  it { expect(facility).to be_valid }

  describe "validations" do
    it { expect(facility).to validate_presence_of(:name) }

    context "when verified" do
      subject(:facility) { build(:facility, :with_verified) }

      it { expect(facility).to validate_presence_of(:lat) }
      it { expect(facility).to validate_presence_of(:long) }
    end

    context "when not verified" do
      subject(:facility) { build(:facility, verified: false) }

      it { expect(facility).not_to validate_presence_of(:lat) }
      it { expect(facility).not_to validate_presence_of(:long) }
    end
  end

  describe "associations" do
    it { expect(facility).to belong_to(:user).optional }
    it { expect(facility).to belong_to(:zone).optional }
    it { expect(facility).to have_many(:facility_welcomes).dependent(:destroy) }
    it { expect(facility).to have_many(:facility_services).dependent(:destroy) }
    it { expect(facility).to have_many(:services).through(:facility_services) }
    it { expect(facility).to have_many(:schedules).class_name("FacilitySchedule").dependent(:destroy) }
    it { expect(facility).to have_many(:time_slots).through(:schedules) }
  end

  describe "discard_reason enum" do
    it "defines enum values" do
      expect(Facility.discard_reasons).to eq({ "none" => nil, "closed" => "closed", "duplicated" => "duplicated" })
    end
  end

  include_examples :discardable do
    subject(:model) { facility }
  end

  describe "#discard_reason" do
    subject(:facility) { build(:facility) }

    before do
      facility.discard_reason = discard_reason
    end

    context "with none" do
      let(:discard_reason) { :none }

      it { expect(facility).to be_discard_reason_none }
    end

    context "with closed" do
      let(:discard_reason) { :closed }

      it { expect(facility).to be_discard_reason_closed }
    end

    context "with duplicated" do
      let(:discard_reason) { :duplicated }

      it { expect(facility).to be_discard_reason_duplicated }
    end
  end

  describe "scopes" do
    describe ".live" do
      subject { described_class.live }

      let(:live_facility) { create(:facility, :with_verified) }
      let(:pending_facility) { create(:facility, verified: false) }
      let(:discarded_facility) { create(:facility, :with_verified).tap(&:discard) }

      it { expect(subject).to include(live_facility) }
      it { expect(subject).not_to include(pending_facility) }
      it { expect(subject).not_to include(discarded_facility) }
    end

    describe ".is_verified" do
      subject { described_class.is_verified }

      let(:verified_facility) { create(:facility, :with_verified) }
      let(:unverified_facility) { create(:facility) }

      it { expect(subject).to include(verified_facility) }
      it { expect(subject).not_to include(unverified_facility) }
    end

    describe ".pending_reviews" do
      subject { described_class.pending_reviews }

      let(:verified_facility) { create(:facility, :with_verified) }
      let(:pending_facility) { create(:facility, verified: false) }
      let(:discarded_facility) { create(:facility).tap(&:discard) }

      it { expect(subject).not_to include(verified_facility) }
      it { expect(subject).to include(pending_facility) }
      it { expect(subject).not_to include(discarded_facility) }
    end

    describe ".with_service" do
      subject { described_class.with_service(service_key_or_name) }

      let(:service) { create(:service, key: "housing", name: "Housing") }
      let(:facility_with_service) { create(:facility).tap { |f| f.services << service } }
      let(:facility_without_service) { create(:facility) }

      context "with service key" do
        let(:service_key_or_name) { "housing" }

        it { expect(subject).to include(facility_with_service) }
        it { expect(subject).not_to include(facility_without_service) }
      end

      context "with service name" do
        let(:service_key_or_name) { "Housing" }

        it { expect(subject).to include(facility_with_service) }
        it { expect(subject).not_to include(facility_without_service) }
      end
    end

    describe ".external" do
      subject { described_class.external }

      let(:external_facility) { create(:facility, external_id: "ext-123") }
      let(:internal_facility) { create(:facility, external_id: nil) }

      it { expect(subject).to include(external_facility) }
      it { expect(subject).not_to include(internal_facility) }
    end

    describe ".not_external" do
      subject { described_class.not_external }

      let(:external_facility) { create(:facility, external_id: "ext-123") }
      let(:internal_facility) { create(:facility, external_id: nil) }

      it { expect(subject).not_to include(external_facility) }
      it { expect(subject).to include(internal_facility) }
    end
  end

  describe "#managed_by?" do
    let(:user) { create(:user) }
    let(:facility) { create(:facility, user: facility_user) }
    let(:zone) { create(:zone) }
    let(:zone_admin) { create(:user, :verified) }

    before do
      facility.update(zone: zone)
      zone.users << zone_admin
    end

    context "when user is facility owner" do
      let(:facility_user) { user }

      it { expect(facility.managed_by?(user)).to be true }
    end

    context "when user is zone admin" do
      let(:facility_user) { create(:user) }

      it { expect(facility.managed_by?(zone_admin)).to be true }
    end

    context "when user is unrelated" do
      let(:facility_user) { create(:user) }
      let(:unrelated_user) { create(:user) }

      it { expect(facility.managed_by?(unrelated_user)).to be false }
    end
  end

  describe ".managed_by" do
    let(:user) { create(:user, :verified) }
    let(:own_facility) { create(:facility, user: user) }
    let(:other_facility) { create(:facility) }

    it { expect(described_class.managed_by(user)).to include(own_facility) }
    it { expect(described_class.managed_by(user)).not_to include(other_facility) }
  end

  describe "#status" do
    context "when discarded" do
      let(:facility) { create(:facility).tap(&:discard) }

      it { expect(facility.status).to eq(:discarded) }
    end

    context "when verified" do
      let(:facility) { create(:facility, :with_verified) }

      it { expect(facility.status).to eq(:live) }
    end

    context "when not verified and not discarded" do
      let(:facility) { create(:facility, verified: false) }

      it { expect(facility.status).to eq(:pending_reviews) }
    end
  end

  describe "#update_status" do
    let(:facility) { create(:facility, verified: false, lat: 49.245, long: -123.028) }

    context "to live" do
      it { expect { facility.update_status(:live) }.to change(facility, :verified).to(true) }
      it { expect(facility.update_status(:live)).to be true }
    end

    context "to pending_reviews" do
      before { facility.update(verified: true) }

      it { expect { facility.update_status(:pending_reviews) }.to change(facility, :verified).to(false) }
      it { expect(facility.update_status(:pending_reviews)).to be true }
    end
  end

  describe "#website_url" do
    context "with no website" do
      let(:facility) { build(:facility, website: nil) }

      it { expect(facility.website_url).to be_nil }
    end

    context "with website having https scheme" do
      let(:facility) { build(:facility, website: "https://example.com") }

      it { expect(facility.website_url).to eq("https://example.com") }
    end

    context "with website missing scheme" do
      let(:facility) { build(:facility, website: "example.com") }

      it { expect(facility.website_url).to eq("https://example.com") }
    end
  end

  describe "#coordinates" do
    let(:facility) { build(:facility, lat: 49.245, long: -123.028) }

    it { expect(facility.coordinates).to eq([49.245, -123.028]) }
  end

  describe "#coord" do
    let(:facility) { build(:facility, lat: 49.245, long: -123.028) }

    it "returns GeoLocation::Coord struct" do
      expect(facility.coord).to be_a(GeoLocation::Coord)
    end
  end

  describe "#distance_in_meters" do
    let(:facility) { build(:facility, lat: 49.245, long: -123.028) }
    let(:other_facility) { build(:facility, lat: 49.282, long: -123.119) }

    it "returns distance in meters" do
      expect(facility.distance_in_meters(to_facility: other_facility)).to be_a(Numeric)
    end
  end

  describe "#distance_in_kms" do
    let(:facility) { build(:facility, lat: 49.245, long: -123.028) }
    let(:other_facility) { build(:facility, lat: 49.282, long: -123.119) }

    it "returns distance in kilometers" do
      expect(facility.distance_in_kms(to_facility: other_facility)).to be_a(Numeric)
    end
  end

  describe "#external?" do
    context "with external_id" do
      let(:facility) { build(:facility, external_id: "ext-123") }

      it { expect(facility.external?).to be true }
    end

    context "without external_id" do
      let(:facility) { build(:facility, external_id: nil) }

      it { expect(facility.external?).to be false }
    end
  end

  describe "#clean_data callback" do
    context "strips whitespace from text fields" do
      let(:facility) do
        build(:facility,
              name: "  Test Facility  ",
              phone: "  123  ",
              website: "  example.com  ",
              address: "  123 Main St  ")
      end

      before { facility.valid? }

      it { expect(facility.name).to eq("Test Facility") }
      it { expect(facility.phone).to eq("123") }
      it { expect(facility.website).to eq("example.com") }
      it { expect(facility.address).to eq("123 Main St") }
    end

    context "sets discard_reason to none when undiscarded" do
      let(:facility) { create(:facility, discard_reason: :closed) }

      before do
        facility.undiscard
        facility.save!
      end

      it { expect(facility.discard_reason).to eq("none") }
    end
  end
end
