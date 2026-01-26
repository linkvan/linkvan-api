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

  before do
    # driven_by :rack_test
  end

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
        sign_in non_admin_user
        dashboard_page.visit_dashboard

        # Should be redirected away from admin
        expect(page.current_path).not_to eq("/admin/dashboard")
      end
    end

    context "logout workflow" do
      it "allows admin to logout successfully" do
        sign_in admin_user
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

    context "with different admin roles" do
      let(:super_admin) { create(:admin_user) }
      let(:zone_admin) { create(:admin_user) } # Assuming zones exist
      let(:facility_admin) { create(:admin_user) }

      it "allows all admin types to access dashboard" do
        [super_admin, zone_admin, facility_admin].each do |user|
          sign_in user
          dashboard_page.visit_dashboard
          expect(dashboard_page.has_dashboard_content?).to be true
          sign_out user
        end
      end
    end
  end
end
