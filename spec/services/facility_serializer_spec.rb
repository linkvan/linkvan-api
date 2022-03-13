require "rails_helper"

RSpec.shared_context "has the correct attributes" do
  facility_attribs = %i[id name phone lat long services schedule zone updated_at]

  # All included Facility atributes
  facility_attribs.each do |field|
    it { is_expected.to include(field) }
  end
end

describe FacilitySerializer do
  let(:fac_service1) { create(:facility_service, facility: facility) }
  let(:fac_service2) { create(:facility_service, facility: facility) }

  let(:always_closed_facility) { create(:close_all_day_facility, :with_services) }
  let(:all_day_facility) { create(:open_all_day_facility, :with_services) }
  let(:now_open_facility) { create(:open_facility, :with_services) }
  let(:now_open2_facility) { create(:open_facility_with_2_time_slots) }

  describe "#call" do
    subject(:returned_data) { call.data }

    let(:call) { described_class.call(facility) }

    context "when complete" do
      subject(:returned_keys) { returned_data.stringify_keys.keys }

      let(:call) { described_class.call(facility, complete: true) }
      let(:facility) { now_open_facility }
      let(:expected_keys) { Facility.attribute_names + %w[schedule zone services welcomes] }

      it { expect(returned_keys.count).to eq(expected_keys.count) }
      it { is_expected.to contain_exactly(*expected_keys) }
    end

    context "when facility is always closed" do
      let(:facility) { always_closed_facility }

      it_behaves_like "has the correct attributes"

      it { expect(returned_data[:services].count).to eq(facility.services.count) }
    end

    context "when facility is always open" do
      let(:facility) { all_day_facility }

      it_behaves_like "has the correct attributes"

      it { expect(returned_data[:services].count).to eq(facility.services.count) }
    end

    context "when facility has time slots" do
      context "with 1 time slot" do
        let(:facility) { now_open_facility }

        it_behaves_like "has the correct attributes"

        it { expect(returned_data[:services].count).to eq(facility.services.count) }
      end

      context "with 2 time slots" do
        let(:facility) { now_open2_facility }

        it_behaves_like "has the correct attributes"
      end
    end
  end
end
