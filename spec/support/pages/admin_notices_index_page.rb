# frozen_string_literal: true

require_relative "base_page"

class AdminNoticesIndexPage < BasePage
  def visit_notices
    visit_page admin_notices_path
    self
  end

  def has_notices_list?
    has_content?("Notices")
  end

  def has_notice?(title)
    has_content?(title)
  end

  def click_new_notice
    click_link "New Notice"
  end

  def click_edit_notice(title)
    within_notice_row(title) { click_link "Edit" }
  end

  def click_show_notice(title)
    within_notice_row(title) { click_link "Show" }
  end

  def click_delete_notice(title)
    within_notice_row(title) do
      accept_confirm { click_link "Delete" }
    end
  end

  private

  def within_notice_row(title, &)
    within("tr", text: title, &)
  end
end
