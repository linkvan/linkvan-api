require "rails_helper"

# RSpec.describe Users::StatusComponent, type: [:view, :component] do
RSpec.describe Users::StatusComponent, type: :component do
  subject(:component) { described_class.new(user) }

  let(:user) { create(:user) }

  it { expect { render_inline(component) }.not_to raise_exception }

  context "when user is verified" do
    let(:user) { create(:user, verified: true) }

    before do
      render_inline(component)
    end

    it { expect(rendered_component).to have_selector ".icon .fa-user-check" }
  end

  context "when user is not verified" do
    let(:user) { create(:user, verified: false) }

    before do
      render_inline(component)
    end

    it { expect(rendered_component).to have_selector ".icon .fa-user-times" }
  end

  context "with show_title" do
    subject(:component) { described_class.new(user, show_title: show_title) }

    let(:show_title) { true }

    before do
      render_inline(component)
    end

    it { expect(rendered_component).to have_text "Verified" }
  end
end
