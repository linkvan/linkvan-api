# frozen_string_literal: true

require "rails_helper"
require_relative "../../support/pages/admin_facilities_index_page"
require_relative "../../support/shared_contexts/admin_authentication"

RSpec.describe "Admin Search and Filtering", type: :system do
  include_context "with admin authentication"
  let(:facilities_index_page) { AdminFacilitiesIndexPage.new }

  describe "facility filtering by status" do
    it "shows only live facilities when filtered" do
      create(:facility, :with_verified, name: "Live Facility")
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_status("Live")

      expect(facilities_index_page.has_facility?("Live Facility")).to be true
      expect(facilities_index_page.has_no_content?("Pending Facility")).to be true
      expect(facilities_index_page.has_no_content?("Discarded Facility")).to be true
    end

    it "shows only pending reviews facilities when filtered" do
      create(:facility, verified: false, name: "Pending Facility")
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_status("Pending Reviews")

      expect(facilities_index_page.has_facility?("Pending Facility")).to be true
      expect(facilities_index_page.has_no_content?("Live Facility")).to be true
      expect(facilities_index_page.has_no_content?("Discarded Facility")).to be true
    end

    it "shows only discarded facilities when filtered" do
      create(:facility, name: "Discarded Facility").tap(&:discard)
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_status("Discarded")

      expect(facilities_index_page.has_facility?("Discarded Facility")).to be true
      expect(facilities_index_page.has_no_content?("Live Facility")).to be true
      expect(facilities_index_page.has_no_content?("Pending Facility")).to be true
    end
  end

  describe "facility filtering by service" do
    it "shows facilities with specific service" do
      service = create(:service, name: "WiFi", key: "wifi")
      facility_with_service = create(:facility, name: "WiFi Facility", verified: true)
      facility_with_service.services << service
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_service("WiFi")

      expect(facilities_index_page.has_facility?("WiFi Facility")).to be true
      expect(facilities_index_page.has_no_content?("No WiFi Facility")).to be true
    end

    it 'shows facilities without services when "none" selected' do
      service = create(:service, name: "WiFi", key: "wifi")
      facility_with_service = create(:facility, name: "WiFi Facility", verified: true)
      facility_with_service.services << service
      create(:facility, name: "No WiFi Facility", verified: true)
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_service("none")

      expect(facilities_index_page.has_facility?("No WiFi Facility")).to be true

      # More specific check - the facility card should not exist (to avoid matching dropdown)
      expect(page).to have_no_selector("#facility_#{facility_with_service.id}")
    end
  end

  describe "facility filtering by welcome customer" do
    it "shows facilities with specific welcome type" do
      facility_with_welcome = create(:facility, name: "Welcoming Facility", verified: true)
      create(:facility_welcome, facility: facility_with_welcome, customer: :male)
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_welcome_customer("male")

      expect(facilities_index_page.has_facility?("Welcoming Facility")).to be true
      expect(facilities_index_page.has_no_content?("Not Welcoming Facility")).to be true
    end

    it 'shows facilities without welcome when "none" selected' do
      facility_with_welcome = create(:facility, name: "Welcoming Facility", verified: true)
      create(:facility_welcome, facility: facility_with_welcome, customer: :male)
      create(:facility, name: "Not Welcoming Facility", verified: true)
      facilities_index_page.visit_facilities
      facilities_index_page.filter_by_welcome_customer("none")

      expect(facilities_index_page.has_facility?("Not Welcoming Facility")).to be true

      # More specific check - the facility card should not exist (to avoid matching dropdown)
      expect(page).to have_no_selector("#facility_#{facility_with_welcome.id}")
    end
  end

  describe "search by name and address" do
    it "finds facilities by name" do
      create(:facility, name: "Downtown Center", address: "123 Main St", verified: true)
      facilities_index_page.visit_facilities
      facilities_index_page.search_facilities("Downtown")

      expect(facilities_index_page.has_facility?("Downtown Center")).to be true
      expect(facilities_index_page.has_no_content?("Uptown Clinic")).to be true
      expect(facilities_index_page.has_no_content?("Rural Clinic")).to be true
    end

    it "finds facilities by address" do
      create(:facility, name: "Downtown Center", address: "123 Main St", verified: true)
      create(:facility, name: "Uptown Clinic", address: "456 Main Avenue", verified: true)
      facilities_index_page.visit_facilities
      facilities_index_page.search_facilities("Main")

      expect(facilities_index_page.has_facility?("Downtown Center")).to be true
      expect(facilities_index_page.has_facility?("Uptown Clinic")).to be true
      expect(facilities_index_page.has_no_content?("Rural Clinic")).to be true
    end

    it "finds facilities by partial match" do
      create(:facility, name: "Uptown Clinic", address: "456 Main Avenue", verified: true)
      create(:facility, name: "Rural Clinic", address: "789 Oak St", verified: true)
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
