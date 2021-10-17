require "rails_helper"

RSpec.shared_context "includes another time slot same to_hour" do
  context "with same to_hour" do
    let(:to_hour) { 11 }

    it { expect(overlaps).to eq(true) }
    it { expect(overlapping_time_slots).to include(another_time_slot) }
    it { expect(overlapping_time_slots.count).to eq(1) }
  end
end

RSpec.shared_context "includes another time slot to_hour before" do
  context "with to_hour before" do
    let(:to_hour) { 10 }

    it { expect(overlaps).to eq(true) }
    it { expect(overlapping_time_slots).to include(another_time_slot) }
    it { expect(overlapping_time_slots.count).to eq(1) }
  end
end

RSpec.shared_context "includes another time slot to_hour after" do
  context "with to_hour after" do
    let(:to_hour) { 12 }

    it { expect(overlaps).to eq(true) }
    it { expect(overlapping_time_slots).to include(another_time_slot) }
    it { expect(overlapping_time_slots.count).to eq(1) }
  end
end

RSpec.describe FacilityTimeSlot, type: :model do
  subject(:facility_time_slot) { build(:facility_time_slot) }

  it { expect(facility_time_slot).to be_valid }

  # For each case, see: https://stackoverflow.com/questions/13513932/algorithm-to-detect-overlapping-periods
  describe ".overlapping_time_slots" do
    subject(:overlapping_time_slots) { facility_time_slot.overlapping_time_slots }

    let(:facility_time_slot) { build(:facility_time_slot, facility_schedule: facility_schedule, **time_params) }
    let(:facility_schedule) { another_time_slot.facility_schedule }
    let(:another_time_slot) { create(:facility_time_slot, from_hour: 9, from_min: 30, to_hour: 11, to_min: 30) }

    let(:time_params) { { from_hour: from_hour, from_min: from_min, to_hour: to_hour, to_min: to_min } }

    let(:overlaps) do
      start_time1 = "9:30".to_time
      end_time1 = "11:30".to_time
      start_time2 = "#{from_hour}:#{from_min}".to_time
      end_time2 = "#{to_hour}:#{to_min}".to_time

      overlaps?(start_time1, end_time1, start_time2, end_time2)
    end

    context "when starts before another" do
      # A starts before B
      # let(:time_params) { { from_hour: from_hour, from_min: 15, to_hour: to_hour, to_min: to_min } }
      let(:from_min) { 15 }

      # Case 1
      context "when ends before another" do
        # A ends before B ends

        let(:to_min) { 15 }

        context "with from_hour before" do
          let(:from_hour) { 8 }

          include_examples "includes another time slot same to_hour"
          include_examples "includes another time slot to_hour before"
        end

        context "with same from_hour" do
          let(:from_hour) { 9 }

          include_examples "includes another time slot same to_hour"
          include_examples "includes another time slot to_hour before"
        end
      end

      # Case 4
      context "when ends after another" do
        # A ends after B ends
        let(:to_min) { 45 }

        context "with from_hour before" do
          let(:from_hour) { 8 }

          include_examples "includes another time slot same to_hour"
          include_examples "includes another time slot to_hour after"
        end

        context "with same from_hour" do
          let(:from_hour) { 9 }

          include_examples "includes another time slot same to_hour"
          include_examples "includes another time slot to_hour before"
        end
      end
    end

    context "when starts after" do
      # A starts after B
      # let(:time_params) { { from_hour: from_hour, from_min: 15, to_hour: to_hour, to_min: to_min } }
      let(:from_min) { 15 }

      # Case 3
      context "when ends before another" do
        # A ends before B ends
        let(:to_min) { 15 }

        context "with from_hour after" do
          let(:from_hour) { 10 }

          include_examples "includes another time slot same to_hour"
          include_examples "includes another time slot to_hour before"
        end

        context "with same from_hour" do
          let(:from_hour) { 9 }

          include_examples "includes another time slot same to_hour"
          include_examples "includes another time slot to_hour before"
        end
      end

      # Case 2
      context "when ends after another" do
        # A ends after B ends
        let(:to_min) { 45 }

        context "with from_hour after" do
          let(:from_hour) { 10 }

          include_examples "includes another time slot same to_hour"
          include_examples "includes another time slot to_hour after"
        end

        context "with same from_hour" do
          let(:from_hour) { 9 }

          include_examples "includes another time slot same to_hour"
          include_examples "includes another time slot to_hour before"
        end
      end
    end

    # Case 5 (A-B)
    context "when starts after another ends" do
      # A starts after B ends
      let(:from_hour) { 11 }
      let(:from_min) { 45 }
      let(:to_hour) { 12 }
      let(:to_min) { 15 }

      it { expect(overlaps).to eq(false) }
      it { expect(overlapping_time_slots).not_to include(another_time_slot) }
      it { expect(overlapping_time_slots.count).to eq(0) }
    end

    # Case 5 (A-C)
    context "when ends before another starts" do
      # A ends before B starts
      let(:from_hour) { 11 }
      let(:from_min) { 45 }
      let(:to_hour) { 13 }
      let(:to_min) { 45 }

      it { expect(overlaps).to eq(false) }
      it { expect(overlapping_time_slots).not_to include(another_time_slot) }
      it { expect(overlapping_time_slots.count).to eq(0) }
    end
  end

  def overlaps?(start_time1, end_time1, start_time2, end_time2)
    start_time1 <= end_time2 && end_time1 >= start_time2
  end
end
