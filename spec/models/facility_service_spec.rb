require "rails_helper"

RSpec.describe FacilityService, type: :model do
  subject(:facility_service) { build(:facility_service) }

  it { expect(facility_service).to be_valid }

  describe "validations" do
    it "validates uniqueness of service within facility" do
      existing = create(:facility_service)
      duplicate = build(:facility_service, facility: existing.facility, service: existing.service)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:service]).to include("has already been taken")
    end
  end

  describe "associations" do
    it { expect(facility_service).to belong_to(:facility).touch(true) }
    it { expect(facility_service).to belong_to(:service) }
  end

  describe "delegates" do
    it { expect(facility_service).to delegate_method(:key).to(:service) }
    it { expect(facility_service).to delegate_method(:name).to(:service) }
  end

  describe "#key" do
    let(:service) { create(:service, key: "housing") }
    let(:facility_service) { build(:facility_service, service: service) }

    it "delegates to service" do
      expect(facility_service.key).to eq("housing")
    end
  end

  describe "#name" do
    let(:service) { create(:service, name: "Housing Services") }
    let(:facility_service) { build(:facility_service, service: service) }

    it "delegates to service" do
      expect(facility_service.name).to eq("Housing Services")
    end
  end

  describe "scopes" do
    describe ".name_search" do
      subject(:searched_facility_services) { described_class.name_search(value) }

      let(:service) { create(:service, key: "housing", name: "Housing") }
      let(:facility_with_housing) { create(:facility) }
      let(:facility_service_housing) { create(:facility_service, facility: facility_with_housing, service: service) }
      let(:facility_service_other) { create(:facility_service) }

      context "with matching service key" do
        let(:value) { "housing" }

        it { expect(searched_facility_services).to include(facility_service_housing) }
        it { expect(searched_facility_services).not_to include(facility_service_other) }
      end
    end
  end

  describe "touch behavior" do
    let(:facility) { create(:facility) }
    let(:service) { create(:service) }
    let(:original_updated_at) { 1.hour.ago }

    before do
      facility.update(updated_at: original_updated_at)
    end

    it "updates facility timestamp on create" do
      create(:facility_service, facility: facility, service: service)
      expect(facility.reload.updated_at).to be > original_updated_at
    end

    it "updates facility timestamp on update" do
      facility_service = create(:facility_service, facility: facility, service: service)
      # rubocop:disable Rails/SkipsModelValidations
      facility_service.touch
      # rubocop:enable Rails/SkipsModelValidations
      expect(facility.reload.updated_at).to be > original_updated_at
    end
  end
end
