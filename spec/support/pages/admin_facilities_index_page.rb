# frozen_string_literal: true

require_relative "base_page"

class AdminFacilitiesIndexPage < BasePage
  def visit_facilities
    visit_page admin_facilities_path
    self
  end

  def has_facilities_list?
    has_content?("Facilities")
  end

  def has_facility?(name)
    has_content?(name)
  end

  def click_new_facility
    click_link "New Facility"
  end

  def click_edit_facility(name)
    within_facility_card(name) { click_link name } # Go to show page
    click_link "Edit" # Edit button is on show page
  end

  def click_show_facility(name)
    within_facility_card(name) { click_link name }
  end

  def click_delete_facility(name, reason: :closed)
    within_facility_card(name) { click_link name } # Go to show page
    click_link "Discard" # Open custom modal

    # Wait for modal to appear and be visible
    expect(page).to have_selector("#reason_modal.is-active", wait: 5)

    # Select discard reason from dropdown
    select Facilities::DiscardReasonComponent::VALID_REASONS[reason], from: "facility_discard_reason"

    # Click the Discard button in the modal
    page.click_button "Discard", class: "is-success"
    self
  end

  def filter_by_status(status)
    # Normalize display text to expected parameter format
    status_mapping = {
      "Live" => "live",
      "Pending Reviews" => "pending_reviews",
      "Discarded" => "discarded"
    }

    normalized_status = status_mapping[status] || status

    # Instead of relying on JavaScript auto-submit (which doesn't work in test environment),
    # directly visit the URL with query parameters to simulate form submission
    visit_page admin_facilities_path(status: normalized_status)
    self
  end

  def search_facilities(query)
    # For search, directly visit with query parameter
    visit_page admin_facilities_path(q: query)
    self
  end

  def filter_by_service(service)
    if [:none, "none"].include?(service)
      visit_page admin_facilities_path(service: :none)
    else
      visit_page admin_facilities_path(service: service)
    end
    self
  end

  def filter_by_welcome_customer(customer_value)
    if [:none, "none"].include?(customer_value)
      visit_page admin_facilities_path(welcome_customer: :none)
    else
      visit_page admin_facilities_path(welcome_customer: customer_value)
    end
    self
  end

  def has_no_facilities_message?
    has_content?("No facilities found")
  end

  private

  def within_facility_card(name, &)
    facility = Facility.find_by(name: name)
    within("#facility_#{facility.id}", &)
  end
end
