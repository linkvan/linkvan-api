# frozen_string_literal: true

require_relative "base_page"

class AdminDashboardPage < BasePage
  def visit_dashboard
    visit_page admin_root_path
    self
  end

  def has_dashboard_content?
    has_content?("Facilities") || has_content?("Users") || has_content?("Notices") || page.has_css?("nav")
  end

  def click_facilities_link
    click_link "Facilities"
  end

  def click_users_link
    click_link "Users"
  end

  def click_notices_link
    click_link "Notices"
  end

  def click_alerts_link
    click_link "Alerts"
  end

  def logout
    click_link "Logout"
  end
end
