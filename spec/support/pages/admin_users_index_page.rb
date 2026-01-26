# frozen_string_literal: true

require_relative "base_page"

class AdminUsersIndexPage < BasePage
  def visit_users
    visit_page admin_users_path
    self
  end

  def has_users_list?
    has_content?("Users")
  end

  def has_user?(email)
    has_content?(email)
  end

  def click_new_user
    click_link "New User"
  end

  def click_edit_user(email)
    within_user_row(email) { click_link "Edit" }
  end

  def click_delete_user(email)
    within_user_row(email) do
      accept_confirm { click_link "Delete" }
    end
  end

  private

  def within_user_row(email, &)
    within("tr", text: email, &)
  end
end
