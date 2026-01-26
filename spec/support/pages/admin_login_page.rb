# frozen_string_literal: true

require_relative "base_page"

class AdminLoginPage < BasePage
  def visit_login
    visit_page new_user_session_path
    self
  end

  def login(email:, password:)
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Log in"
    self
  end

  def has_login_form?
    has_content?("Log in")
  end

  def has_error_message?
    has_content?("Invalid") || has_content?("Invalid Email or password") || page.has_css?(".alert") || page.has_css?(".notification.is-danger")
  end
end
