require "rails_helper"

RSpec.describe Shared::ModalCardComponent, type: :component do
  subject(:component) { described_class.new(id: id, title: title) }

  let(:id) { "test-modal" }
  let(:title) { "Test Modal Title" }

  describe "initialization" do
    it "sets the id attribute" do
      expect(component.id).to eq(id)
    end

    it "sets the title attribute" do
      expect(component.title).to eq(title)
    end

    context "when id is not provided" do
      subject(:component) { described_class.new(title: title) }

      it "sets id to nil" do
        expect(component.id).to be_nil
      end
    end

    context "when title is not provided" do
      subject(:component) { described_class.new(id: id) }

      it "sets title to nil" do
        expect(component.title).to be_nil
      end
    end
  end

  describe "rendering" do
    it "renders without error" do
      expect { render_inline(component) }.not_to raise_exception
    end

    it "renders the modal container with correct id" do
      render_inline(component)
      expect(rendered_content).to have_css("div##{id}.modal.modal_card")
    end

    it "renders the modal background" do
      render_inline(component)
      expect(rendered_content).to have_css(".modal-background")
    end

    it "renders the modal card structure" do
      render_inline(component)
      expect(rendered_content).to have_css(".modal-card")
      expect(rendered_content).to have_css(".modal-card-head")
      expect(rendered_content).to have_css(".modal-card-body")
      expect(rendered_content).to have_css(".modal-card-foot")
    end

    it "renders the title in the modal card head" do
      render_inline(component)
      expect(rendered_content).to have_css(".modal-card-title", text: title)
    end

    it "renders the close button in the header" do
      render_inline(component)
      expect(rendered_content).to have_css("button.delete[aria-label='close'][data-bulma-modal='close']")
    end

    context "when id is nil" do
      subject(:component) { described_class.new(title: title) }

      it "renders the modal with an empty id attribute" do
        render_inline(component)
        expect(rendered_content).to have_css("div.modal.modal_card[id='']")
      end
    end

    context "when title is nil" do
      subject(:component) { described_class.new(id: id) }

      it "renders the modal card title as empty" do
        render_inline(component)
        expect(rendered_content).to have_css(".modal-card-title", text: "")
      end
    end
  end

  describe "content" do
    let(:content_text) { "Modal content goes here" }

    before do
      render_inline(component) { content_text }
    end

    it "renders the content in the modal body" do
      expect(rendered_content).to have_css(".modal-card-body", text: content_text)
    end
  end

  describe "action_buttons" do
    let(:button1_text) { "Button 1" }
    let(:button2_text) { "Button 2" }

    before do
      component.with_action_button { button1_text }
      component.with_action_button { button2_text }
      render_inline(component)
    end

    it "renders the action buttons in the footer" do
      expect(rendered_content).to have_css(".modal-card-foot", text: button1_text)
      expect(rendered_content).to have_css(".modal-card-foot", text: button2_text)
    end

    it "does not render the default close button when action buttons are present" do
      expect(rendered_content).not_to have_css("button.button", text: "Close")
    end
  end

  describe "default close button" do
    before do
      render_inline(component)
    end

    it "renders the default close button when no action buttons are present" do
      expect(rendered_content).to have_css("button.button[data-bulma-modal='close']", text: "Close")
    end
  end

  describe "action button component" do
    let(:action_button_content) { "Custom Button" }

    it "renders the action button content" do
      component.with_action_button { action_button_content }
      render_inline(component)
      expect(rendered_content).to have_text(action_button_content)
    end
  end

  describe "edge cases" do
    context "when both id and title are nil" do
      subject(:component) { described_class.new }

      it "renders without error" do
        expect { render_inline(component) }.not_to raise_exception
      end

      it "renders the modal structure correctly" do
        render_inline(component)
        expect(rendered_content).to have_css(".modal.modal_card")
        expect(rendered_content).to have_css(".modal-card-title", text: "")
      end
    end

    context "with empty action buttons" do
      before do
        render_inline(component)
      end

      it "renders the default close button" do
        expect(rendered_content).to have_css("button.button", text: "Close")
      end
    end
  end
end
