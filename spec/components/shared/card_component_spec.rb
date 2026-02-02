require "rails_helper"

# RSpec.describe Shared::CardComponent, type: [:view, :component] do
RSpec.describe Shared::CardComponent, type: :component do
  subject(:component) { described_class.new(title: title) }

  let(:title) { "A Title" }

  it { expect { render_inline(component) }.not_to raise_exception }
  it { expect(render_inline(component)).to have_text title }

  describe "action_content" do
    let(:first_action_content) { { title: "CARD ACTION CONTENT 1", path: "action1" } }
    let(:second_action_content) { { title: "CARD ACTION CONTENT 2", path: "action2" } }

    before do
      component.with_button(**first_action_content)
      component.with_button(**second_action_content)

      render_inline(component)
    end

    it { expect(rendered_content).to have_text first_action_content[:title] }
    it { expect(rendered_content).to have_text second_action_content[:title] }
  end

  describe "content" do
    let(:content) { "THE CARD CONTENT" }

    before do
      render_inline(component) { content }
    end

    it { expect(rendered_content).to have_text content }
  end
end
