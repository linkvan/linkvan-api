require "rails_helper"

RSpec.describe Alerts::ShowComponent, type: :component do
  subject(:component) { described_class.new(alert: alert) }

  let(:alert) { create(:alert, title: "Sample Alert", content: "Sample content", active: false) }

  it { expect { render_inline(component) }.not_to raise_exception }

  describe "#alert_dom_id" do
    it "returns the dom_id for the alert" do
      expect(component.alert_dom_id).to eq("alert_#{alert.id}")
    end
  end

  context "when rendering the component" do
    before do
      render_inline(component)
    end

    it "displays alert title" do
      expect(rendered_content).to have_text(alert.title)
    end

    it "displays alert status as Not Active" do
      expect(rendered_content).to have_text("Not Active")
    end

    it "displays alert content" do
      expect(rendered_content).to have_text(alert.content.to_plain_text)
    end

    it "displays last updated time" do
      expect(rendered_content).to have_selector("time[datetime='#{alert.updated_at}']")
    end

    it "renders edit button" do
      expect(rendered_content).to have_link("Edit")
    end

    it "renders delete button" do
      expect(rendered_content).to have_link("Delete")
    end

    it "has three card components" do
      expect(rendered_content).to have_selector(".card", count: 3)
    end

    it "has the correct dom id" do
      expect(rendered_content).to have_selector("#alert_#{alert.id}")
    end
  end

  context "with an active alert" do
    let(:alert) { create(:alert, :active, title: "Active Alert", content: "Active content") }

    before do
      render_inline(component)
    end

    it "displays alert status as Active" do
      expect(rendered_content).to have_text("Active")
    end

    it "displays alert title" do
      expect(rendered_content).to have_text(alert.title)
    end
  end

  context "with an inactive alert" do
    let(:alert) { create(:alert, :inactive, title: "Inactive Alert", content: "Inactive content") }

    before do
      render_inline(component)
    end

    it "displays alert status as Not Active" do
      expect(rendered_content).to have_text("Not Active")
    end
  end

  context "with rich text content" do
    let(:alert) { create(:alert, content: "Rich text content") }

    before do
      render_inline(component)
    end

    it "displays the rich text content" do
      expect(rendered_content).to have_text("Rich text content")
    end
  end
end
