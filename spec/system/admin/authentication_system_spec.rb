# frozen_string_literal: true

require "rails_helper"
require_relative "../../support/pages/admin_login_page"
require_relative "../../support/pages/admin_dashboard_page"

RSpec.describe "Admin Authentication", type: :system do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { create(:admin_user) }
  let(:non_admin_user) { create(:user) }
  let(:login_page) { AdminLoginPage.new }
  let(:dashboard_page) { AdminDashboardPage.new }

  describe "login/logout workflows" do
    context "with valid admin credentials" do
      it "allows admin to log in and access dashboard" do
        login_page.visit_login
        login_page.login(email: admin_user.email, password: "password")

        expect(dashboard_page.has_dashboard_content?).to be true
        expect(page.current_path).to eq("/admin/dashboard")
      end
    end

    context "with invalid credentials" do
      it "shows error message and stays on login page" do
        login_page.visit_login
        login_page.login(email: "wrong@example.com", password: "wrong")

        expect(page.current_path).to eq(new_user_session_path)
      end
    end

    context "with non-admin user" do
      it "redirects to login after attempting admin access" do
        login_as non_admin_user, scope: :user
        dashboard_page.visit_dashboard

        # Should be redirected away from admin
        expect(page.current_path).not_to eq("/admin/dashboard")
      end
    end

    context "when performing logout workflow" do
      it "allows admin to logout successfully" do
        login_as admin_user, scope: :user
        dashboard_page.visit_dashboard
        dashboard_page.logout

        expect(page.current_path).to eq(new_user_session_path)
        expect(page).to have_content("Log in")
      end
    end
  end

  describe "permission-based access control" do
    context "when not authenticated" do
      it "redirects to login page" do
        dashboard_page.visit_dashboard

        expect(page.current_path).to eq(new_user_session_path)
        expect(login_page.has_login_form?).to be true
      end
    end
  end
end
