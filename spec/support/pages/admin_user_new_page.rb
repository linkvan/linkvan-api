# frozen_string_literal: true

require_relative "base_page"

class AdminUserNewPage < BasePage
  def visit_new_user
    visit_page new_admin_user_path
    self
  end

  def create_user(attributes = {})
    fill_in "Name", with: attributes[:name] || "Test User"
    fill_in "Email", with: attributes[:email] || "test@example.com"
    fill_in "user_password", with: attributes[:password] || "password123"
    fill_in "user_password_confirmation", with: attributes[:password_confirmation] || "password123"
    check "Admin" if attributes[:admin]
    click_button "Create User"
  end

  def has_form_errors?
    has_content?("can't be blank") || has_css?(".field_with_errors")
  end
end
