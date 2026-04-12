# frozen_string_literal: true

require_relative "base_page"

class AdminToolsPage < BasePage
  def visit_tools
    visit_page admin_tools_path
    self
  end

  def has_tools_content?
    has_content?("Tools") && has_content?("Vancouver City API")
  end

  def has_sync_tab?
    page.has_css?(".tabs ul li", text: "Sync")
  end

  def has_discard_tab?
    page.has_css?(".tabs ul li", text: "Discard")
  end

  def click_sync_tab
    click_link "Sync"
    self
  end

  def click_discard_tab
    click_link "Discard"
    self
  end

  def has_import_form?
    page.has_css?("#import-form")
  end

  def has_discard_form?
    page.has_css?("#discard-form")
  end
end
