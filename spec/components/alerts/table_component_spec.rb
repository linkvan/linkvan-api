require "rails_helper"

RSpec.describe Alerts::TableComponent, type: :component do
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers

  subject(:component) { described_class.new(alerts: alerts) }

  let(:alerts) { create_list(:alert, 3) }

  it { expect { render_inline(component) }.not_to raise_exception }

  context "when rendering the component with multiple alerts" do
    before do
      render_inline(component)
    end

    it "renders a table" do
      expect(rendered_content).to have_selector("table")
    end

    it "renders table headers" do
      expect(rendered_content).to have_selector("thead th", text: "Status")
      expect(rendered_content).to have_selector("thead th", text: "Title")
      expect(rendered_content).to have_selector("thead th", text: "Content")
      expect(rendered_content).to have_selector("thead th", text: "Updated At")
      expect(rendered_content).to have_selector("thead th", text: "MORE")
    end

    it "renders a row for each alert" do
      expect(rendered_content).to have_selector("tbody tr", count: 3)
    end

    it "displays each alert's title as a link" do
      alerts.each do |alert|
        expect(rendered_content).to have_link(alert.title, href: admin_alert_path(id: alert.id))
      end
    end

    it "displays each alert's status" do
      alerts.each do |alert|
        expected_status = alert.active? ? "Active" : "Not Active"
        expect(rendered_content).to have_text(expected_status)
      end
    end

    it "displays each alert's content truncated" do
      alerts.each do |alert|
        truncated_content = truncate(alert.content.to_plain_text, length: 80)
        expect(rendered_content).to have_text(truncated_content)
      end
    end

    it "displays each alert's updated at" do
      alerts.each do |alert|
        expect(rendered_content).to have_text(alert.updated_at.to_s)
      end
    end

    it "renders MORE column for each alert" do
      expect(rendered_content).to have_selector("tbody tr td:last-child", text: "", count: 3)
    end
  end

  context "when rendering with active alerts" do
    let(:alerts) { create_list(:alert, 2, :active) }

    before do
      render_inline(component)
    end

    it "displays status as Active" do
      expect(rendered_content).to have_text("Active", count: 2)
    end
  end

  context "when rendering with inactive alerts" do
    let(:alerts) { create_list(:alert, 2, :inactive) }

    before do
      render_inline(component)
    end

    it "displays status as Not Active" do
      expect(rendered_content).to have_text("Not Active", count: 2)
    end
  end

  context "when rendering with alerts having long content" do
    let(:alerts) { [create(:alert, content: "<p>#{'a' * 100}</p>")] }

    before do
      render_inline(component)
    end

    it "truncates content to 80 characters" do
      alert = alerts.first
      truncated_content = truncate(alert.content.to_plain_text, length: 80)
      expect(rendered_content).to have_text(truncated_content)
      expect(truncated_content.length).to eq(80)
    end
  end

  context "when rendering with an empty alerts collection" do
    let(:alerts) { [] }

    before do
      render_inline(component)
    end

    it "renders a table with no rows" do
      expect(rendered_content).to have_selector("table")
      expect(rendered_content).to have_selector("tbody tr", count: 0)
    end
  end

  context "when rendering with a single alert" do
    let(:alerts) { create_list(:alert, 1) }

    before do
      render_inline(component)
    end

    it "renders one row" do
      expect(rendered_content).to have_selector("tbody tr", count: 1)
    end

    it "displays the alert's details correctly" do
      alert = alerts.first
      expected_status = alert.active? ? "Active" : "Not Active"
      truncated_content = truncate(alert.content.to_plain_text, length: 80)
      expect(rendered_content).to have_link(alert.title, href: admin_alert_path(id: alert.id))
      expect(rendered_content).to have_text(expected_status)
      expect(rendered_content).to have_text(truncated_content)
      expect(rendered_content).to have_text(alert.updated_at.to_s)
    end
  end

  describe "AlertRowComponent" do
    subject(:row_component) { described_class::AlertRowComponent.new(alert, table_component: component) }

    let(:alert) { create(:alert) }

    it { expect { render_inline(row_component) }.not_to raise_exception }

    context "when rendering the row component" do
      before do
        render_inline(row_component)
      end

      it "displays alert title as link" do
        expect(rendered_content).to have_link(alert.title, href: admin_alert_path(id: alert.id))
      end

      it "displays alert status" do
        expected_status = alert.active? ? "Active" : "Not Active"
        expect(rendered_content).to have_text(expected_status)
      end

      it "displays alert content truncated" do
        truncated_content = truncate(alert.content.to_plain_text, length: 80)
        expect(rendered_content).to have_text(truncated_content)
      end

      it "displays alert updated at" do
        expect(rendered_content).to have_text(alert.updated_at.to_s)
      end

      it "renders the more menu placeholder" do
        expect(rendered_content).to have_selector("td")
      end
    end
  end

  describe "MoreMenuComponent" do
    subject(:menu_component) { described_class::MoreMenuComponent.new(alert: alert) }

    let(:alert) { create(:alert) }

    it { expect { render_inline(menu_component) }.not_to raise_exception }

    context "when rendering the menu component" do
      before do
        render_inline(menu_component)
      end

      it "renders dropdown menu" do
        expect(rendered_content).to have_selector(".dropdown")
      end
    end
  end
end
