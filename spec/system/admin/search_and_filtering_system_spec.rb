# frozen_string_literal: true

require "rails_helper"
require_relative "../../support/pages/admin_facilities_index_page"
require_relative "../../support/shared_contexts/admin_authentication"

RSpec.describe "Admin Search and Filtering", type: :system do
  include_context "admin authentication"
  let(:facilities_index_page) { AdminFacilitiesIndexPage.new }

  describe "facility filtering by status" do
    let!(:live_facility) { create(:facility, :with_verified, name: "Live Facility") }
    let!(:pending_facility) { create(:facility, verified: false, name: "Pending Facility") }
    let!(:discarded_facility) { create(:facility, name: "Discarded Facility").tap(&:discard) }

    it "shows only live facilities when filtered" do
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_status("Live")

      expect(facilities_index_page.has_facility?("Live Facility")).to be true
      expect(facilities_index_page.has_no_content?("Pending Facility")).to be true
      expect(facilities_index_page.has_no_content?("Discarded Facility")).to be true
    end

    it "shows only pending reviews facilities when filtered" do
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_status("Pending Reviews")

      expect(facilities_index_page.has_facility?("Pending Facility")).to be true
      expect(facilities_index_page.has_no_content?("Live Facility")).to be true
      expect(facilities_index_page.has_no_content?("Discarded Facility")).to be true
    end

    it "shows only discarded facilities when filtered" do
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_status("Discarded")

      expect(facilities_index_page.has_facility?("Discarded Facility")).to be true
      expect(facilities_index_page.has_no_content?("Live Facility")).to be true
      expect(facilities_index_page.has_no_content?("Pending Facility")).to be true
    end
  end

  describe "facility filtering by service" do
    let!(:service) { create(:service, name: "WiFi", key: "wifi") }
    let!(:facility_with_service) { create(:facility, name: "WiFi Facility", verified: true) }
    let!(:facility_without_service) { create(:facility, name: "No WiFi Facility", verified: true) }

    before do
      facility_with_service.services << service
    end

    it "shows facilities with specific service" do
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_service("WiFi")

      expect(facilities_index_page.has_facility?("WiFi Facility")).to be true
      expect(facilities_index_page.has_no_content?("No WiFi Facility")).to be true
    end

    it 'shows facilities without services when "none" selected' do
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_service("none")

      expect(facilities_index_page.has_facility?("No WiFi Facility")).to be true

      # More specific check - the facility card should not exist (to avoid matching dropdown)
      wifi_facility = Facility.find_by(name: "WiFi Facility")
      expect(page).to have_no_selector("#facility_#{wifi_facility.id}")
    end
  end

  describe "facility filtering by welcome customer" do
    let!(:facility_with_welcome) { create(:facility, name: "Welcoming Facility", verified: true) }
    let!(:facility_without_welcome) { create(:facility, name: "Not Welcoming Facility", verified: true) }

    before do
      create(:facility_welcome, facility: facility_with_welcome, customer: :male)
    end

    it "shows facilities with specific welcome type" do
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_welcome_customer("male")

      expect(facilities_index_page.has_facility?("Welcoming Facility")).to be true
      expect(facilities_index_page.has_no_content?("Not Welcoming Facility")).to be true
    end

    it 'shows facilities without welcome when "none" selected' do
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_welcome_customer("none")

      expect(facilities_index_page.has_facility?("Not Welcoming Facility")).to be true

      # More specific check - the facility card should not exist (to avoid matching dropdown)
      welcoming_facility = Facility.find_by(name: "Welcoming Facility")
      expect(page).to have_no_selector("#facility_#{welcoming_facility.id}")
    end
  end

  describe "search by name and address" do
    let!(:facility_by_name) { create(:facility, name: "Downtown Center", address: "123 Main St", verified: true) }
    let!(:facility_by_address) { create(:facility, name: "Uptown Clinic", address: "456 Main Avenue", verified: true) }
    let!(:other_facility) { create(:facility, name: "Rural Clinic", address: "789 Oak St", verified: true) }

    it "finds facilities by name" do
      facilities_index_page.visit_facilities
      facilities_index_page.search_facilities("Downtown")

      expect(facilities_index_page.has_facility?("Downtown Center")).to be true
      expect(facilities_index_page.has_no_content?("Uptown Clinic")).to be true
      expect(facilities_index_page.has_no_content?("Rural Clinic")).to be true
    end

    it "finds facilities by address" do
      facilities_index_page.visit_facilities
      facilities_index_page.search_facilities("Main")

      expect(facilities_index_page.has_facility?("Downtown Center")).to be true
      expect(facilities_index_page.has_facility?("Uptown Clinic")).to be true
      expect(facilities_index_page.has_no_content?("Rural Clinic")).to be true
    end

    it "finds facilities by partial match" do
      facilities_index_page.visit_facilities
      facilities_index_page.search_facilities("Clinic")

      expect(facilities_index_page.has_facility?("Uptown Clinic")).to be true
      expect(facilities_index_page.has_facility?("Rural Clinic")).to be true
      expect(facilities_index_page.has_no_content?("Downtown Center")).to be true
    end

    it "shows no results for non-matching search" do
      facilities_index_page.visit_facilities
      facilities_index_page.search_facilities("Nonexistent")

      expect(facilities_index_page.has_no_facilities_message?).to be true
    end
  end
end
