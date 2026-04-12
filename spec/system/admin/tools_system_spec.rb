# frozen_string_literal: true

require "rails_helper"
require_relative "../../support/pages/admin_tools_page"
require_relative "../../support/shared_contexts/admin_authentication"

RSpec.describe "Admin Tools", type: :system do
  include_context "with admin authentication"

  let(:tools_page) { AdminToolsPage.new }

  describe "page load" do
    it "loads without errors" do
      tools_page.visit_tools
      expect(page.current_path).to eq(admin_tools_path)
      expect(tools_page.has_tools_content?).to be true
    end

    it "displays Vancouver City API section" do
      tools_page.visit_tools
      expect(page).to have_content("Vancouver City API")
    end

    it "displays Sync and Purge tabs" do
      tools_page.visit_tools
      expect(tools_page.has_sync_tab?).to be true
      expect(tools_page.has_purge_tab?).to be true
    end

    it "shows Sync tab content by default" do
      tools_page.visit_tools
      expect(tools_page.has_import_form?).to be true
    end

    it "switches to Purge tab when clicked" do
      tools_page.visit_tools
      tools_page.click_purge_tab
      expect(tools_page.has_purge_form?).to be true
    end
  end
end
