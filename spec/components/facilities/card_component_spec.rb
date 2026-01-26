require "rails_helper"

RSpec.describe Facilities::CardComponent, type: :component do
  subject(:component) { described_class.new(facility: facility) }

  let(:facility) { create(:facility) }

  describe "#initialize" do
    it "assigns the facility" do
      expect(component.facility).to eq(facility)
    end
  end

  describe "#card_id" do
    it "returns dom_id of the facility" do
      expect(component.card_id).to eq("facility_#{facility.id}")
    end
  end

  describe "#status_component" do
    it "returns a Facilities::StatusComponent with facility status" do
      expect(component.status_component).to be_a(Facilities::StatusComponent)
      expect(component.status_component.status).to eq(facility.status)
    end
  end

  describe "rendering" do
    before { render_inline(component) }

    it "renders without error" do
      expect { render_inline(component) }.not_to raise_exception
    end

    it "renders a card with facility class and id" do
      expect(rendered_content).to have_css("div.card.facility.mb-2")
      expect(rendered_content).to have_css("div.card.facility.mb-2[id]")
    end

    it "renders the facility name as a link" do
      expect(rendered_content).to have_link(facility.name)
      expect(rendered_content).to have_css("a[href*='/admin/facilities/#{facility.id}']", text: facility.name)
    end

    describe "status display" do
      it "renders status icon component" do
        expect(rendered_content).to have_css(".icon")
      end

      it "renders status title component" do
        expect(rendered_content).to have_text(facility.status.to_s.titleize)
      end
    end

    describe "services section" do
      context "when facility has services" do
        let(:facility) { create(:facility, :with_services) }

        it "renders service tags" do
          facility.services.each do |service|
            expect(rendered_content).to have_css("span.tag.is-light", text: service.name)
          end
        end

        it "does not render none tag for services" do
          expect(rendered_content).to have_css("span.tag.is-danger", text: "None", count: 1) # only for welcomes
        end
      end

      context "when facility has no services" do
        it "renders none tag for services" do
          expect(rendered_content).to have_css("span.tag.is-danger", text: "None", count: 2) # for services and welcomes
        end
      end
    end

    describe "welcomes section" do
      context "when facility has welcomes" do
        let(:welcome) { create(:facility_welcome) }
        let(:facility) { welcome.facility }

        it "renders welcome icons" do
          expect(rendered_content).to have_css("div.svg-icons")
        end

        it "does not render none tag for welcomes" do
          expect(rendered_content).to have_css("span.tag.is-danger", text: "None", count: 1) # only for services
        end
      end

      context "when facility has no welcomes" do
        it "renders none tag for welcomes" do
          expect(rendered_content).to have_css("span.tag.is-danger", text: "None", count: 2) # for services and welcomes
        end
      end
    end

    it "renders the facility address" do
      expect(rendered_content).to have_text(facility.address)
    end

    describe "user section" do
      context "when facility has a user" do
        let(:user) { create(:user) }
        let(:facility) { create(:facility, user: user) }

        it "renders user status component" do
          expect(rendered_content).to have_css(".level-item")
        end

        it "renders user name and email" do
          expect(rendered_content).to have_text(user.name)
          expect(rendered_content).to have_text(user.email)
        end

        it "does not render not present tag" do
          expect(rendered_content).not_to have_css("span.tag.is-danger", text: "Not Present")
        end
      end

      context "when facility has no user" do
        it "renders not present tag" do
          expect(rendered_content).to have_css("span.tag.is-danger", text: "Not Present")
        end
      end
    end

    describe "footer" do
      it "renders last updated time" do
        expect(rendered_content).to have_text("Last Updated on")
        expect(rendered_content).to have_css("time[datetime='#{facility.updated_at}']")
        expect(rendered_content).to have_text(facility.updated_at.to_s)
      end
    end
  end

  describe "with different facility statuses" do
    context "when facility is live" do
      let(:facility) { create(:facility, :with_verified) }

      before { render_inline(component) }

      it "renders live status icon" do
        expect(rendered_content).to have_css(".icon.has-text-success .fas.fa-check-square")
      end

      it "renders live status title" do
        expect(rendered_content).to have_text("Live")
      end
    end

    context "when facility is pending reviews" do
      before { render_inline(component) }

      it "renders pending status icon" do
        expect(rendered_content).to have_css(".icon.has-text-danger .fas.fa-times")
      end

      it "renders pending status title" do
        expect(rendered_content).to have_text("Pending Reviews")
      end
    end

    context "when facility is discarded" do
      let(:facility) { create(:facility).tap(&:discard) }

      before { render_inline(component) }

      it "renders discarded status icon" do
        expect(rendered_content).to have_css(".icon.has-text-warning .fas.fa-minus-circle")
      end

      it "renders discarded status title" do
        expect(rendered_content).to have_text("Discarded")
      end
    end
  end

  describe "edge cases" do
    context "when facility has blank address" do
      let(:facility) { create(:facility, address: "") }

      it "renders without error" do
        expect { render_inline(component) }.not_to raise_exception
      end
    end

    context "when facility has no associated data" do
      it "renders basic structure" do
        render_inline(component)
        expect(rendered_content).to have_css("div.card.facility")
        expect(rendered_content).to have_link(facility.name)
      end
    end
  end
end
