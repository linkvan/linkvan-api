require "rails_helper"

RSpec.describe Facilities::WelcomesIconComponent, type: :component do
  subject(:component) { described_class.new(welcomes, variant: variant) }

  let(:variant) { :full }

  describe "with valid welcome types" do
    described_class::ICONS.each do |welcome_type, expected_icon|
      context "when welcomes is '#{welcome_type}'" do
        let(:welcomes) { welcome_type }

        it "renders without error" do
          expect { render_inline(component) }.not_to raise_exception
        end

        context "with full variant" do
          let(:variant) { :full }

          before do
            render_inline(component)
          end

          it "renders a div with svg-icon class" do
            expect(rendered_content).to have_css("div.svg-icon.ml-1")
          end

          it "renders the correct icon" do
            expect(rendered_content).to have_css("svg")
          end
        end

        context "with icon variant" do
          let(:variant) { :icon }

          before do
            render_inline(component)
          end

          it "renders a span with icon class" do
            expect(rendered_content).to have_css("span.icon")
          end

          it "renders the correct icon" do
            expect(rendered_content).to have_css("svg")
          end

          it "does not show error message for icon variant" do
            expect(rendered_content).not_to have_css("span.tag.is-danger")
          end
        end

        describe "#icon_location" do
          it "returns the correct icon path" do
            expect(component.icon_location).to eq("icons/#{expected_icon}")
          end
        end
      end
    end
  end

  describe "with string welcome types" do
    context "when welcomes is a string that matches a valid type" do
      let(:welcomes) { "female" }

      it "renders without error" do
        expect { render_inline(component) }.not_to raise_exception
      end

      it "converts string to symbol correctly" do
        expect(component.icon_location).to eq("icons/female.svg")
      end
    end

    context "when welcomes is a camelCase string" do
      let(:welcomes) { "maleTransgender" }

      it "converts camelCase to underscore" do
        # The component should convert "maleTransgender" to "male_transgender"
        expect(component.instance_variable_get(:@welcomes)).to eq(:male_transgender)
      end
    end
  end

  describe "with invalid welcome types" do
    context "when welcomes is not in the ICONS hash" do
      let(:welcomes) { "invalid_type" }

      before do
        render_inline(component)
      end

      it "still attempts to render the icon div for full variant" do
        expect(rendered_content).to have_css("div.svg-icon.ml-1")
      end
    end

    context "when welcomes is nil" do
      let(:welcomes) { nil }

      before do
        render_inline(component)
      end

      it "handles nil gracefully" do
        expect(rendered_content).to have_css("div.svg-icon.ml-1")
      end
    end
  end

  describe "variant parameter" do
    let(:welcomes) { :female }

    context "when variant is :full (default)" do
      let(:variant) { :full }

      before do
        render_inline(component)
      end

      it "renders the full variant structure" do
        expect(rendered_content).to have_css("div.svg-icon.ml-1")
      end
    end

    context "when variant is :icon" do
      let(:variant) { :icon }

      before do
        render_inline(component)
      end

      it "renders only the icon variant structure" do
        expect(rendered_content).to have_css("span.icon")
        expect(rendered_content).not_to have_css("div.svg-icon")
      end
    end

    context "when variant is not specified" do
      subject(:component) { described_class.new(welcomes) }

      let(:welcomes) { :female }

      before do
        render_inline(component)
      end

      it "defaults to full variant" do
        expect(rendered_content).to have_css("div.svg-icon.ml-1")
      end
    end
  end

  describe "logging" do
    let(:welcomes) { :female }

    it "logs debug information during initialization" do
      expect(Rails.logger).to receive(:debug)
      described_class.new(welcomes)
    end
  end

  describe "all defined icon types" do
    it "has icons defined for all expected welcome types" do
      expected_types = %i[female male transgender children youth adult senior]
      expect(described_class::ICONS.keys).to match_array(expected_types)
    end

    it "has valid file extensions for all icons" do
      described_class::ICONS.values.each do |icon_file|
        expect(icon_file).to end_with(".svg")
      end
    end
  end

  describe "icon_location method" do
    context "when welcome type exists in ICONS" do
      let(:welcomes) { :female }

      it "returns the correct path" do
        expect(component.icon_location).to eq("icons/female.svg")
      end
    end

    context "when welcome type does not exist in ICONS" do
      let(:welcomes) { :nonexistent }

      it "returns path with nil filename" do
        expect(component.icon_location).to eq("icons/error.svg")
      end
    end
  end
end
