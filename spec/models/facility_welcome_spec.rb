require "rails_helper"

RSpec.describe FacilityWelcome, type: :model do
  subject(:facility_welcome) { build(:facility_welcome) }

  it { expect(facility_welcome).to be_valid }

  describe "validations" do
    it { expect(facility_welcome).to validate_presence_of(:customer) }

    it "validates uniqueness of customer within facility" do
      existing = create(:facility_welcome, customer: :male)
      duplicate = build(:facility_welcome, facility: existing.facility, customer: :male)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:customer]).to include("has already been taken")
    end
  end

  describe "associations" do
    it { expect(facility_welcome).to belong_to(:facility).touch(true) }
  end

  describe "customer enum" do
    it "defines customer as a string enum" do
      welcome = create(:facility_welcome, customer: "male")
      expect(welcome.male?).to be true
      expect(welcome.female?).to be false

      welcome.update!(customer: "female")
      expect(welcome.female?).to be true
    end

    it "has all expected customer types" do
      expect(described_class.customers.keys).to eq(%w[male female transgender children youth adult senior])
    end
  end

  describe "#name" do
    context "with male" do
      let(:facility_welcome) { build(:facility_welcome, customer: :male) }

      it { expect(facility_welcome.name).to eq("Male") }
    end

    context "with children" do
      let(:facility_welcome) { build(:facility_welcome, customer: :children) }

      it { expect(facility_welcome.name).to eq("Children") }
    end

    context "with senior" do
      let(:facility_welcome) { build(:facility_welcome, customer: :senior) }

      it { expect(facility_welcome.name).to eq("Senior") }
    end
  end

  describe ".all_customers" do
    it "returns array of OpenStruct objects with name and value" do
      customers = described_class.all_customers

      expect(customers).to be_an(Array)
      expect(customers.length).to eq(7)

      expect(customers.find { |c| c.value == "male" }.name).to eq("Male")
      expect(customers.find { |c| c.value == "female" }.name).to eq("Female")
      expect(customers.find { |c| c.value == "transgender" }.name).to eq("Transgender")
      expect(customers.find { |c| c.value == "children" }.name).to eq("Children")
      expect(customers.find { |c| c.value == "youth" }.name).to eq("Youth")
      expect(customers.find { |c| c.value == "adult" }.name).to eq("Adult")
      expect(customers.find { |c| c.value == "senior" }.name).to eq("Senior")
    end
  end

  describe ".names" do
    it "returns array of customer names" do
      names = described_class.names

      expect(names).to be_an(Array)
      expect(names).to include("Male", "Female", "Transgender", "Children", "Youth", "Adult", "Senior")
    end
  end

  describe "scopes" do
    describe ".name_search" do
      subject(:searched_facility_welcomes) { described_class.name_search(value) }

      let(:facility) { create(:facility) }
      let(:male_welcome) { create(:facility_welcome, facility: facility, customer: :male) }
      let(:female_welcome) { create(:facility_welcome, facility: facility, customer: :female) }

      context "with exact match" do
        let(:value) { "male" }

        it { expect(searched_facility_welcomes).to include(male_welcome) }
        it { expect(searched_facility_welcomes).not_to include(female_welcome) }
      end

      context "with different case" do
        let(:value) { "MALE" }

        it { expect(searched_facility_welcomes).to include(male_welcome) }
      end
    end
  end

  describe "touch behavior" do
    let(:facility) { create(:facility) }
    let(:original_updated_at) { 1.hour.ago }

    before do
      facility.update(updated_at: original_updated_at)
    end

    it "updates facility timestamp on create" do
      create(:facility_welcome, facility: facility)
      expect(facility.reload.updated_at).to be > original_updated_at
    end

    it "updates facility timestamp on update" do
      facility_welcome = create(:facility_welcome, facility: facility)
      # rubocop:disable Rails/SkipsModelValidations
      facility_welcome.touch
      # rubocop:enable Rails/SkipsModelValidations
      expect(facility.reload.updated_at).to be > original_updated_at
    end
  end

  describe "factory" do
    it "creates facility welcome with male customer by default" do
      expect(build(:facility_welcome).customer).to eq("male")
    end
  end
end
