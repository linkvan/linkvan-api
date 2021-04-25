require "rails_helper"

# RSpec.describe Shared::CardComponent, type: [:view, :component] do
RSpec.describe Shared::CardComponent, type: :component do
  subject(:component) { described_class.new(title: title) }

  let(:title) { 'A Title' }

  it { expect { render_inline(component) }.not_to raise_exception }
  it { expect(render_inline(component)).to have_text title }

  describe "action_content" do
    let(:content1) { "CARD ACTION CONTENT 1" }
    let(:content2) { "CARD ACTION CONTENT 2" }
    before do
      component.action_content { content1 }
      component.action_content { content2 }

      render_inline(component)
    end

    it { expect(rendered_component).to have_text content1 }
    it { expect(rendered_component).to have_text content2 }
  end

  describe "content" do
    let(:content) { "THE CARD CONTENT" }

    before do
      render_inline(component) { content }
    end

    it { expect(rendered_component).to have_text content }
  end
end
