# frozen_string_literal: true

shared_context "admin authentication" do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { create(:admin_user) }
  let(:login_page) { AdminLoginPage.new }

  before do
    login_page.visit_login
    login_page.login(email: admin_user.email, password: "password")
  end
end
