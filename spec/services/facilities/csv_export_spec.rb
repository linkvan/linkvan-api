# frozen_string_literal: true

require "rails_helper"

RSpec.describe Facilities::CsvExporter do
  describe ".call" do
    subject(:result) { described_class.call(facilities) }

    let(:facilities) { Facility.where(id: facility.id) }

    context "with a basic facility" do
      let(:facility) { create(:facility, name: "Test Facility", address: "123 Main St") }

      it "returns a successful result" do
        expect(result).to be_success
      end

      it "returns CSV data" do
        expect(result.data).to be_a(String)
      end

      it "includes headers" do
        expect(result.data).to include("ID,Name,Status,Address")
      end

      it "includes facility data" do
        expect(result.data).to include("Test Facility")
        expect(result.data).to include("123 Main St")
      end

      it "includes status" do
        expect(result.data).to include("Pending Reviews")
      end
    end

    context "with a verified facility" do
      let(:facility) { create(:facility, :with_verified, name: "Live Facility") }

      it "shows Live status" do
        expect(result.data).to include("Live")
      end
    end

    context "with a discarded facility" do
      let(:facility) { create(:facility, name: "Discarded Facility").tap(&:discard) }

      it "shows Discarded status" do
        expect(result.data).to include("Discarded")
      end
    end

    context "with services" do
      let(:facility) { create(:facility) }
      let(:service) { create(:service, name: "Haircut") }

      before do
        create(:facility_service, facility: facility, service: service, note: "Walk-ins only")
      end

      it "includes service name with note" do
        expect(result.data).to include("Haircut (Walk-ins only)")
      end

      context "when service has no note" do
        before do
          facility.facility_services.first.update!(note: nil)
        end

        it "includes just service name" do
          expect(result.data).to include("Haircut")
          expect(result.data).not_to include("Haircut ()")
        end
      end
    end

    context "with welcomes" do
      let(:facility) { create(:facility) }

      before do
        create(:facility_welcome, facility: facility, customer: :male)
        create(:facility_welcome, facility: facility, customer: :female)
      end

      it "includes welcome names comma-separated" do
        expect(result.data).to include("Male, Female")
      end
    end

    context "with zone" do
      let(:zone) { create(:zone, name: "Downtown Zone") }
      let(:facility) { create(:facility, zone: zone) }

      it "includes zone name" do
        expect(result.data).to include("Downtown Zone")
      end
    end

    context "with schedules" do
      context "when closed all day" do
        let(:facility) { create(:facility) }

        before do
          create(:facility_schedule, facility: facility, week_day: :monday, closed_all_day: true)
        end

        it "shows Closed for that day" do
          csv = CSV.parse(result.data, headers: true)
          expect(csv.first["Monday"]).to eq("Closed")
        end
      end

      context "when open all day" do
        let(:facility) { create(:facility) }

        before do
          create(:facility_schedule, facility: facility, week_day: :tuesday, open_all_day: true, closed_all_day: false)
        end

        it "shows Open All Day for that day" do
          csv = CSV.parse(result.data, headers: true)
          expect(csv.first["Tuesday"]).to eq("Open All Day")
        end
      end

      context "with time slots" do
        let(:facility) { create(:facility) }

        before do
          schedule = create(:facility_schedule, facility: facility, week_day: :wednesday, closed_all_day: false, open_all_day: false)
          create(:facility_time_slot, facility_schedule: schedule, from_hour: 9, from_min: 0, to_hour: 12, to_min: 0)
          create(:facility_time_slot, facility_schedule: schedule, from_hour: 13, from_min: 0, to_hour: 17, to_min: 30)
        end

        it "shows time slots comma-separated" do
          csv = CSV.parse(result.data, headers: true)
          wednesday = csv.first["Wednesday"]
          expect(wednesday).to include("09:00 AM - 12:00 PM")
          expect(wednesday).to include("01:00 PM - 05:30 PM")
        end
      end

      context "when no schedule exists for a day" do
        let(:facility) { create(:facility) }

        it "shows Closed for that day" do
          csv = CSV.parse(result.data, headers: true)
          expect(csv.first["Sunday"]).to eq("Closed")
        end
      end
    end

    context "with multiple facilities" do
      let(:facility1) { create(:facility, name: "Facility One") }
      let(:facility2) { create(:facility, name: "Facility Two") }
      let(:facilities) { Facility.where(id: [facility1.id, facility2.id]) }

      it "includes all facilities" do
        expect(result.data).to include("Facility One")
        expect(result.data).to include("Facility Two")
      end

      it "has correct number of rows" do
        csv = CSV.parse(result.data, headers: true)
        expect(csv.length).to eq(2)
      end
    end

    context "with empty facilities" do
      let(:facilities) { Facility.none }

      it "returns only headers" do
        csv = CSV.parse(result.data, headers: true)
        expect(csv.length).to eq(0)
      end
    end
  end
end
