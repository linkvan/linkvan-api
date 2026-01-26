require "rails_helper"

RSpec.describe Notices::TableComponent, type: :component do
  subject(:component) { described_class.new(notices: notices) }

  let(:notices) { create_list(:notice, 3) }

  it { expect { render_inline(component) }.not_to raise_exception }

  context "when rendering the component with multiple notices" do
    before do
      render_inline(component)
    end

    it "renders a table" do
      expect(rendered_content).to have_selector("table")
    end

    it "renders table headers" do
      expect(rendered_content).to have_selector("thead th", text: "Status")
      expect(rendered_content).to have_selector("thead th", text: "Type")
      expect(rendered_content).to have_selector("thead th", text: "Title")
      expect(rendered_content).to have_selector("thead th", text: "Content")
      expect(rendered_content).to have_selector("thead th", text: "Updated At")
      expect(rendered_content).to have_selector("thead th", text: "MORE")
    end

    it "renders a row for each notice" do
      expect(rendered_content).to have_selector("tbody tr", count: 3)
    end

    it "displays each notice's title" do
      notices.each do |notice|
        expect(rendered_content).to have_text(notice.title)
      end
    end

    it "displays each notice's status" do
      notices.each do |notice|
        expect(rendered_content).to have_text(notice.published? ? "Published" : "Draft")
      end
    end

    it "displays each notice's notice type" do
      notices.each do |notice|
        expect(rendered_content).to have_text(notice.notice_type)
      end
    end

    it "displays each notice's last updated date" do
      notices.each do |notice|
        expect(rendered_content).to have_text(notice.updated_at.to_s)
      end
    end

    it "renders action menus for each notice" do
      expect(rendered_content).to have_text("MORE")
    end
  end

  context "when rendering with published notices" do
    let(:notices) { create_list(:notice, 2, :published) }

    before do
      render_inline(component)
    end

    it "displays status as Published" do
      expect(rendered_content).to have_text("Published", count: 2)
    end
  end

  context "when rendering with draft notices" do
    let(:notices) { create_list(:notice, 2, :draft) }

    before do
      render_inline(component)
    end

    it "displays status as Draft" do
      expect(rendered_content).to have_text("Draft", count: 2)
    end
  end

  context "when rendering with different notice types" do
    let(:notices) do
      [
        create(:notice, notice_type: :general),
        create(:notice, notice_type: :covid19),
        create(:notice, notice_type: :warming_center)
      ]
    end

    before do
      render_inline(component)
    end

    it "displays correct notice types" do
      expect(rendered_content).to have_text("general")
      expect(rendered_content).to have_text("covid19")
      expect(rendered_content).to have_text("warming_center")
    end
  end

  context "when rendering with an empty notices collection" do
    let(:notices) { [] }

    before do
      render_inline(component)
    end

    it "renders a table with no rows" do
      expect(rendered_content).to have_selector("table")
      expect(rendered_content).to have_selector("tbody tr", count: 0)
    end
  end

  context "when rendering with a single notice" do
    let(:notices) { create_list(:notice, 1) }

    before do
      render_inline(component)
    end

    it "renders one row" do
      expect(rendered_content).to have_selector("tbody tr", count: 1)
    end

    it "displays the notice's details correctly" do
      notice = notices.first
      expect(rendered_content).to have_text(notice.title)
      expect(rendered_content).to have_text(notice.published? ? "Published" : "Draft")
      expect(rendered_content).to have_text(notice.notice_type)
      expect(rendered_content).to have_text(notice.updated_at.to_s)
    end
  end

  describe "NoticeRowComponent" do
    subject(:row_component) { described_class::NoticeRowComponent.new(notice, table_component: component) }

    let(:notice) { create(:notice) }

    it { expect { render_inline(row_component) }.not_to raise_exception }

    context "when rendering the row component" do
      before do
        render_inline(row_component)
      end

      it "displays notice title" do
        expect(rendered_content).to have_text(notice.title)
      end

      it "displays notice status" do
        expect(rendered_content).to have_text(notice.published? ? "Published" : "Draft")
      end

      it "displays notice type" do
        expect(rendered_content).to have_text(notice.notice_type)
      end

      it "displays last updated" do
        expect(rendered_content).to have_text(notice.updated_at.to_s)
      end
    end
  end

  describe "MoreMenuComponent" do
    subject(:menu_component) { described_class::MoreMenuComponent.new(notice: notice) }

    let(:notice) { create(:notice) }

    it { expect { render_inline(menu_component) }.not_to raise_exception }

    context "when rendering the menu component" do
      before do
        render_inline(menu_component)
      end

      it "renders dropdown menu items" do
        expect(rendered_content).to have_selector(".dropdown-content")
      end
    end
  end
end
