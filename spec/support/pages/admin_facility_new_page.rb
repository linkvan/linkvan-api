# frozen_string_literal: true

require_relative "base_page"

class AdminFacilityNewPage < BasePage
  def visit_new_facility
    visit_page new_admin_facility_path
    self
  end

  def create_facility(attributes = {})
    fill_in "Name", with: attributes[:name] || "Test Facility"
    fill_in "Phone", with: attributes[:phone] || "555-1234"
    fill_in "Website", with: attributes[:website] || "https://test.com"
    fill_in "Notes", with: attributes[:notes] || "Test notes"
    click_button "Create Facility"
  end

  def has_form_errors?
    has_content?("can't be blank") || has_css?(".field_with_errors")
  end
end
