require "rails_helper"

RSpec.describe Facilities::StatusComponent, type: :component do
  subject(:component) { described_class.new(status, variant: variant) }

  let(:variant) { :full }

  context "when status is :live" do
    let(:status) { :live }

    it "renders successfully" do
      expect { render_inline(component) }.not_to raise_exception
    end

    it "renders the live status icon" do
      render_inline(component)

      expect(rendered_content).to have_css("span.icon.has-text-success")
      expect(rendered_content).to have_css("i.fas.fa-check-square")
      expect(rendered_content).to have_css("i[title='Live']")
    end

    context "with variant :title" do
      let(:variant) { :title }

      it "renders only the title" do
        render_inline(component)

        expect(rendered_content).to have_text("Live")
      end
    end
  end

  context "when status is :pending_reviews" do
    let(:status) { :pending_reviews }

    it "renders successfully" do
      expect { render_inline(component) }.not_to raise_exception
    end

    it "renders the pending reviews status icon" do
      render_inline(component)

      expect(rendered_content).to have_css("span.icon.has-text-danger")
      expect(rendered_content).to have_css("i.fas.fa-times")
      expect(rendered_content).to have_css("i[title='Pending Reviews']")
    end

    context "with variant :title" do
      let(:variant) { :title }

      it "renders only the title" do
        render_inline(component)

        expect(rendered_content).to have_text("Pending Reviews")
      end
    end
  end

  context "when status is :discarded" do
    let(:status) { :discarded }

    it "renders successfully" do
      expect { render_inline(component) }.not_to raise_exception
    end

    it "renders the discarded status icon" do
      render_inline(component)

      expect(rendered_content).to have_css("span.icon.has-text-warning")
      expect(rendered_content).to have_css("i.fas.fa-minus-circle")
      expect(rendered_content).to have_css("i[title='Discarded']")
    end

    context "with variant :title" do
      let(:variant) { :title }

      it "renders only the title" do
        render_inline(component)

        expect(rendered_content).to have_text("Discarded")
      end
    end
  end

  context "when status is invalid" do
    let(:status) { :unknown }

    it "renders successfully" do
      expect { render_inline(component) }.not_to raise_exception
    end

    it "renders the default icon" do
      render_inline(component)

      expect(rendered_content).to have_css("span.icon")
      expect(rendered_content).to have_css("i.fas")
      expect(rendered_content).to have_css("i[title='Unknown']")
    end

    context "with variant :title" do
      let(:variant) { :title }

      it "renders only the title" do
        render_inline(component)

        expect(rendered_content).to have_text("Unknown")
      end
    end
  end

  context "when status is passed as string" do
    let(:status) { "live" }

    it "converts to symbol and renders correctly" do
      render_inline(component)

      expect(rendered_content).to have_css("span.icon.has-text-success")
      expect(rendered_content).to have_css("i.fas.fa-check-square")
    end
  end

  context "with facility test data" do
    context "when facility is live" do
      let(:facility) { create(:facility, :with_verified) }
      let(:status) { facility.status }

      it "renders the live status" do
        render_inline(component)

        expect(rendered_content).to have_css("span.icon.has-text-success")
        expect(rendered_content).to have_css("i.fas.fa-check-square")
      end
    end

    context "when facility is pending reviews" do
      let(:facility) { create(:facility) } # default verified: false
      let(:status) { facility.status }

      it "renders the pending reviews status" do
        render_inline(component)

        expect(rendered_content).to have_css("span.icon.has-text-danger")
        expect(rendered_content).to have_css("i.fas.fa-times")
      end
    end

    context "when facility is discarded" do
      let(:facility) { create(:facility).tap(&:discard!) }
      let(:status) { facility.status }

      it "renders the discarded status" do
        render_inline(component)

        expect(rendered_content).to have_css("span.icon.has-text-warning")
        expect(rendered_content).to have_css("i.fas.fa-minus-circle")
      end
    end
  end
end
