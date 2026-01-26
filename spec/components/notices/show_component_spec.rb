require "rails_helper"

RSpec.describe Notices::ShowComponent, type: :component do
  subject(:component) { described_class.new(notice: notice) }

  let(:notice) { create(:notice, title: "Sample Notice", content: "Sample content", published: false, notice_type: :general) }

  it { expect { render_inline(component) }.not_to raise_exception }

  describe "#notice_dom_id" do
    it "returns the dom_id for the notice" do
      expect(component.notice_dom_id).to eq("notice_#{notice.id}")
    end
  end

  context "when rendering the component" do
    before do
      render_inline(component)
    end

    it "displays notice title" do
      expect(rendered_content).to have_text(notice.title)
    end

    it "displays notice status as Draft" do
      expect(rendered_content).to have_text("Draft")
    end

    it "displays notice content" do
      expect(rendered_content).to have_text(notice.content.to_plain_text)
    end

    it "displays last updated time" do
      expect(rendered_content).to have_selector("time[datetime='#{notice.updated_at}']")
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
      expect(rendered_content).to have_selector("#notice_#{notice.id}")
    end
  end

  context "with a published notice" do
    let(:notice) { create(:notice, :published, title: "Published Notice", content: "Published content") }

    before do
      render_inline(component)
    end

    it "displays notice status as Published" do
      expect(rendered_content).to have_text("Published")
    end

    it "displays notice title" do
      expect(rendered_content).to have_text(notice.title)
    end
  end

  context "with a draft notice" do
    let(:notice) { create(:notice, :draft, title: "Draft Notice", content: "Draft content") }

    before do
      render_inline(component)
    end

    it "displays notice status as Draft" do
      expect(rendered_content).to have_text("Draft")
    end
  end

  context "with a notice of different type" do
    let(:notice) { create(:notice, notice_type: :covid19, title: "COVID Notice", content: "COVID content") }

    before do
      render_inline(component)
    end

    it "still renders without error" do
      expect(rendered_content).to have_text(notice.title)
      expect(rendered_content).to have_text(notice.content.to_plain_text)
    end
  end

  context "with rich text content" do
    let(:notice) { create(:notice, content: "Rich text content") }

    before do
      render_inline(component)
    end

    it "displays the rich text content" do
      expect(rendered_content).to have_text("Rich text content")
    end
  end
end
