require "rails_helper"

RSpec.describe Users::ShowComponent, type: :component do
  subject(:component) { described_class.new(user: user) }

  let(:user) { create(:user, organization: "Test Org", phone_number: "123-456-7890") }

  it { expect { render_inline(component) }.not_to raise_exception }

  describe "#card_id" do
    it "returns the dom_id for the user" do
      expect(component.card_id).to eq("user_#{user.id}")
    end
  end

  context "when rendering the component" do
    before do
      render_inline(component)
    end

    it "displays user name" do
      expect(rendered_content).to have_text(user.name)
    end

    it "displays user email" do
      expect(rendered_content).to have_text(user.email)
    end

    it "displays user organization" do
      expect(rendered_content).to have_text(user.organization)
    end

    it "displays user phone number" do
      expect(rendered_content).to have_text(user.phone_number)
    end

    it "displays admin status" do
      expect(rendered_content).to have_text(user.admin.to_s.titleize)
    end

    it "renders the status component" do
      expect(rendered_content).to have_text("Verified")
    end

    it "displays last updated time" do
      expect(rendered_content).to have_selector("time[datetime='#{user.updated_at}']")
    end

    it "renders action buttons" do
      expect(rendered_content).to have_link("Reset Password")
      expect(rendered_content).to have_link("Edit")
      expect(rendered_content).to have_link("Delete")
    end

    it "has two card components" do
      expect(rendered_content).to have_selector(".card", count: 2)
    end
  end

  context "with a verified admin user" do
    let(:user) { create(:admin_user) }

    before do
      render_inline(component)
    end

    it "displays admin as True" do
      expect(rendered_content).to have_text("True")
    end
  end

  context "with an unverified user" do
    let(:user) { create(:user, :not_verified) }

    before do
      render_inline(component)
    end

    it "displays admin as False" do
      expect(rendered_content).to have_text("False")
    end
  end

  context "with a user missing organization" do
    let(:user) { create(:user, organization: nil, phone_number: "123-456-7890") }

    before do
      render_inline(component)
    end

    context "with a user missing phone number" do
      let(:user) { create(:user, organization: "Test Org", phone_number: nil) }

      before do
        render_inline(component)
      end

      it "still renders without error" do
        expect(rendered_content).to have_text("Phone Number:")
      end
    end

    it "still renders without error" do
      expect(rendered_content).to have_text("Organization:")
    end
  end

  context "with a user missing phone number" do
    let(:user) { create(:user, phone_number: nil) }

    before do
      render_inline(component)
    end

    it "still renders without error" do
      expect(rendered_content).to have_text("Phone Number:")
    end
  end
end
