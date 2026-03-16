require "rails_helper"

RSpec.describe FacilitySchedule, type: :model do
  subject(:schedule) { build(:facility_schedule) }

  it { expect(schedule).to be_valid }

  describe "validations" do
    it { expect(schedule).to validate_presence_of(:week_day) }
  end

  describe "associations" do
    it { expect(schedule).to belong_to(:facility).touch(true) }
    it { expect(schedule).to have_many(:time_slots).class_name("FacilityTimeSlot").dependent(:destroy) }
  end

  describe "week_day enum" do
    it "defines week_day as a string enum" do
      schedule = create(:facility_schedule, week_day: "monday")
      expect(schedule.monday?).to be true
      expect(schedule.sunday?).to be false

      schedule.update!(week_day: "tuesday")
      expect(schedule.tuesday?).to be true
    end

    it "has all expected days" do
      expect(described_class.week_days.values).to eq(%w[sunday monday tuesday wednesday thursday friday saturday])
    end
  end

  describe "attributes" do
    describe "closed_all_day" do
      it "defaults to true" do
        expect(schedule.closed_all_day).to be true
      end
    end

    describe "open_all_day" do
      it "defaults to false" do
        expect(schedule.open_all_day).to be false
      end
    end
  end

  describe "scopes" do
    describe ".open_all_day" do
      subject(:open_all_day_schedules) { described_class.open_all_day }

      let(:open_all_day_schedule) { create(:facility_schedule, open_all_day: true, closed_all_day: false) }
      let(:closed_schedule) { create(:facility_schedule, open_all_day: false, closed_all_day: true) }

      it { expect(open_all_day_schedules).to include(open_all_day_schedule) }
      it { expect(open_all_day_schedules).not_to include(closed_schedule) }
    end

    describe ".closed_all_day" do
      subject(:closed_all_day_schedules) { described_class.closed_all_day }

      let(:closed_schedule) { create(:facility_schedule, closed_all_day: true, open_all_day: false) }
      let(:open_schedule) { create(:facility_schedule, open_all_day: true, closed_all_day: false) }

      it { expect(closed_all_day_schedules).to include(closed_schedule) }
      it { expect(closed_all_day_schedules).not_to include(open_schedule) }
    end
  end

  describe "#availability" do
    context "when open_all_day" do
      let(:schedule) { build(:facility_schedule, open_all_day: true) }

      it { expect(schedule.availability).to eq(:open) }
    end

    context "with time slots" do
      let(:schedule) { build(:facility_schedule, :with_time_slot) }

      it { expect(schedule.availability).to eq(:set_times) }
    end

    context "when closed all day" do
      let(:schedule) { build(:facility_schedule, closed_all_day: true, open_all_day: false) }

      it { expect(schedule.availability).to eq(:closed) }
    end
  end

  describe "#update_schedule_availability" do
    let(:schedule) { create(:facility_schedule, closed_all_day: true, open_all_day: false) }

    context "when adding time slots" do
      before do
        schedule.time_slots << build(:facility_time_slot, facility_schedule: schedule)
        schedule.update_schedule_availability
      end

      it { expect(schedule.closed_all_day).to be false }
      it { expect(schedule.open_all_day).to be false }
    end

    context "when removing time slots" do
      before do
        schedule.update_schedule_availability
      end

      it { expect(schedule.closed_all_day).to be true }
      it { expect(schedule.open_all_day).to be false }
    end
  end

  describe "time_slots_presence validation" do
    context "when open_all_day with time slots" do
      let(:schedule) { build(:facility_schedule, open_all_day: true) }

      before do
        schedule.time_slots << build(:facility_time_slot, facility_schedule: schedule)
        schedule.valid?
      end

      it { expect(schedule).not_to be_valid }
      it { expect(schedule.errors[:slot_times]).to be_present }
    end

    context "when closed_all_day with time slots" do
      let(:schedule) { build(:facility_schedule, closed_all_day: true) }

      before do
        schedule.time_slots << build(:facility_time_slot, facility_schedule: schedule)
        schedule.valid?
      end

      it { expect(schedule).not_to be_valid }
      it { expect(schedule.errors[:slot_times]).to be_present }
    end

    context "when open_all_day without time slots" do
      let(:schedule) { build(:facility_schedule, open_all_day: true) }

      it { expect(schedule).to be_valid }
    end

    context "when closed_all_day without time slots" do
      let(:schedule) { build(:facility_schedule, closed_all_day: true) }

      it { expect(schedule).to be_valid }
    end

    context "with time slots and not all day" do
      let(:schedule) { build(:facility_schedule, :with_time_slot) }

      it { expect(schedule).to be_valid }
    end
  end

  describe "week_days" do
    it "returns all week day enum values" do
      expect(described_class.week_days.values).to eq(%w[sunday monday tuesday wednesday thursday friday saturday])
    end
  end
end
