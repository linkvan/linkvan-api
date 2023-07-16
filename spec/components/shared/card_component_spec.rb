require "rails_helper"

# RSpec.describe Shared::CardComponent, type: [:view, :component] do
RSpec.describe Shared::CardComponent, type: :component do
  subject(:component) { described_class.new(title: title) }

  let(:title) { "A Title" }

  it { expect { render_inline(component) }.not_to raise_exception }
  it { expect(render_inline(component)).to have_text title }

  describe "action_content" do
    let(:content1) { { title: "CARD ACTION CONTENT 1", path: "action1" } }
    let(:content2) { { title: "CARD ACTION CONTENT 2", path: "action2" } }
    before do
      component.with_button(**content1)
      component.with_button(**content2)

      render_inline(component)
    end

    it { expect(rendered_content).to have_text content1[:title] }
    it { expect(rendered_content).to have_text content2[:title] }
  end

  describe "content" do
    let(:content) { "THE CARD CONTENT" }

    before do
      render_inline(component) { content }
    end

    it { expect(rendered_content).to have_text content }
  end
end
