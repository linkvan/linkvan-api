# frozen_string_literal: true

require "rails_helper"
require_relative "../../support/pages/admin_users_index_page"
require_relative "../../support/pages/admin_user_new_page"
require_relative "../../support/shared_contexts/admin_authentication"

RSpec.describe "Admin User Management", type: :system do
  include_context "with admin authentication"

  let(:users_index_page) { AdminUsersIndexPage.new }
  let(:user_new_page) { AdminUserNewPage.new }

  # before do
  #   driven_by :rack_test
  # end

  describe "user management workflow" do
    describe "create/edit/delete users" do
      context "when creating a new user" do
        it "allows admin to create a regular user" do
          users_index_page.visit_users
          users_index_page.click_new_user

          user_new_page.create_user(name: "New User", email: "newuser@example.com")

          expect(page).to have_content("Successfully created user")
          expect(users_index_page.has_user?("newuser@example.com")).to be true
        end

        it "allows admin to create an admin user" do
          users_index_page.visit_users
          users_index_page.click_new_user

          user_new_page.create_user(
            name: "New Admin",
            email: "newadmin@example.com",
            admin: true
          )

          expect(page).to have_content("Successfully created user")
          expect(users_index_page.has_user?("newadmin@example.com")).to be true
        end

        it "shows validation errors for invalid data" do
          users_index_page.visit_users
          users_index_page.click_new_user

          user_new_page.create_user(email: "")

          expect(user_new_page.has_form_errors?).to be true
          expect(page).to have_content("Email can't be blank")
        end

        it "shows password mismatch error" do
          users_index_page.visit_users
          users_index_page.click_new_user

          user_new_page.create_user(
            password: "password123",
            password_confirmation: "different"
          )

          expect(user_new_page.has_form_errors?).to be true
          expect(page).to have_content("Password confirmation doesn't match")
        end
      end
    end
  end
end
