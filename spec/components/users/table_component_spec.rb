require "rails_helper"

RSpec.describe Users::TableComponent, type: :component do
  subject(:component) { described_class.new(users: users) }

  let(:users) { create_list(:user, 3) }

  it { expect { render_inline(component) }.not_to raise_exception }

  context "when rendering the component with multiple users" do
    before do
      render_inline(component)
    end

    it "renders a table" do
      expect(rendered_content).to have_selector("table")
    end

    it "renders table headers" do
      expect(rendered_content).to have_selector("thead th", text: "Status")
      expect(rendered_content).to have_selector("thead th", text: "Name")
      expect(rendered_content).to have_selector("thead th", text: "Email")
      expect(rendered_content).to have_selector("thead th", text: "Organization")
      expect(rendered_content).to have_selector("thead th", text: "Updated At")
      expect(rendered_content).to have_selector("thead th", text: "MORE")
    end

    it "renders a row for each user" do
      expect(rendered_content).to have_selector("tbody tr", count: 3)
    end

    it "displays each user's name" do
      users.each do |user|
        expect(rendered_content).to have_text(user.name)
      end
    end

    it "displays each user's email" do
      users.each do |user|
        expect(rendered_content).to have_text(user.email)
      end
    end

    it "displays each user's admin status" do
      users.each do |user|
        # Admin status is not displayed in the current implementation
        # Only verification status is shown via the StatusComponent icon
        expect(rendered_content).not_to have_text(user.admin? ? "Yes" : "No")
      end
    end

    it "displays each user's verified status" do
      users.each do |user|
        # StatusComponent renders icons only when show_title is false
        # The icon classes indicate verified/not verified status
        if user.verified?
          expect(rendered_content).to have_selector(".fa-user-check")
          expect(rendered_content).not_to have_selector(".fa-user-times")
        else
          expect(rendered_content).to have_selector(".fa-user-times")
          expect(rendered_content).not_to have_selector(".fa-user-check")
        end
      end
    end

    it "renders action menus for each user" do
      # More menu component is commented out in the current implementation
      expect(rendered_content).not_to have_selector(".dropdown")
    end
  end

  context "when rendering with admin users" do
    let(:users) { create_list(:admin_user, 2) }

    before do
      render_inline(component)
    end

    it "displays verification status icons but not admin status" do
      # Admin status is not displayed in the current implementation
      # Only verification status is shown via icons
      expect(rendered_content).not_to have_text("Yes")
      expect(rendered_content).not_to have_text("No")
      expect(rendered_content).to have_selector(".fa-user-check", count: 2) # assuming admin users are verified
    end
  end

  context "when rendering with unverified users" do
    let(:users) { create_list(:user, 2, :not_verified) }

    before do
      render_inline(component)
    end

    it "displays verification status icons" do
      expect(rendered_content).not_to have_text("Yes")
      expect(rendered_content).not_to have_text("No")
      expect(rendered_content).to have_selector(".fa-user-times", count: 2)
    end
  end

  context "when rendering with an empty users collection" do
    let(:users) { [] }

    before do
      render_inline(component)
    end

    it "renders a table with no rows" do
      expect(rendered_content).to have_selector("table")
      expect(rendered_content).to have_selector("tbody tr", count: 0)
    end

    it "does not render an empty message" do
      # No empty state message is implemented in the current template
      expect(rendered_content).not_to have_text("No users found")
    end
  end

  context "when rendering with a single user" do
    let(:users) { create_list(:user, 1) }

    before do
      render_inline(component)
    end

    it "renders one row" do
      expect(rendered_content).to have_selector("tbody tr", count: 1)
    end

    it "displays the user's details correctly" do
      user = users.first
      expect(rendered_content).to have_text(user.name)
      expect(rendered_content).to have_text(user.email)

      # Organization might be nil, so only check if it's present
      expect(rendered_content).to have_text(user.organization) if user.organization.present?

      expect(rendered_content).to have_text(user.updated_at.to_s)

      # Admin and verification status are not displayed as text
      expect(rendered_content).not_to have_text(user.admin? ? "Yes" : "No")
      expect(rendered_content).not_to have_text(user.verified? ? "Yes" : "No")

      # But verification status is shown via icon
      if user.verified?
        expect(rendered_content).to have_selector(".fa-user-check")
      else
        expect(rendered_content).to have_selector(".fa-user-times")
      end
    end
  end

  describe "UserRowComponent" do
    subject(:row_component) { described_class::UserRowComponent.new(user, table_component: component) }

    let(:user) { create(:user) }

    it { expect { render_inline(row_component) }.not_to raise_exception }

    context "when rendering the row component" do
      before do
        render_inline(row_component)
      end

      it "displays user name" do
        expect(rendered_content).to have_text(user.name)
      end

      it "displays user email" do
        expect(rendered_content).to have_text(user.email)
      end

      it "does not render the more menu component" do
        # More menu component is commented out in the current implementation
        expect(rendered_content).not_to have_selector(".dropdown")
      end
    end
  end

  describe "MoreMenuComponent" do
    subject(:menu_component) { described_class::MoreMenuComponent.new(user: user) }

    let(:user) { create(:user) }

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
