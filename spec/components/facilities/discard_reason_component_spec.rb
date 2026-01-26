require "rails_helper"

RSpec.describe Facilities::DiscardReasonComponent, type: :component do
  subject(:component) { described_class.new(discard_reason) }

  let(:discard_reason) { :none }

  describe "#initialize" do
    context "when discard_reason is a symbol" do
      let(:discard_reason) { :closed }

      it "sets discard_reason as symbol" do
        expect(component.discard_reason).to eq(:closed)
      end
    end

    context "when discard_reason is a string" do
      let(:discard_reason) { "duplicated" }

      it "converts string to symbol" do
        expect(component.discard_reason).to eq(:duplicated)
      end
    end
  end

  describe "#call" do
    context "with valid discard reasons" do
      Facilities::DiscardReasonComponent::VALID_REASONS.each do |key, expected_text|
        context "when discard_reason is #{key}" do
          let(:discard_reason) { key }

          it "returns the correct text" do
            expect(component.call).to eq(expected_text)
          end
        end
      end
    end

    context "with string inputs" do
      Facilities::DiscardReasonComponent::VALID_REASONS.each do |key, expected_text|
        context "when discard_reason is '#{key}' as string" do
          let(:discard_reason) { key.to_s }

          it "returns the correct text" do
            expect(component.call).to eq(expected_text)
          end
        end
      end
    end

    context "with invalid discard reasons" do
      let(:discard_reason) { :invalid_reason }

      it "returns error message" do
        expect(component.call).to eq("Unsupported value 'invalid_reason'")
      end
    end

    context "with nil discard_reason" do
      let(:discard_reason) { nil }

      it "returns error message for nil" do
        expect(component.call).to eq("Unsupported value ''")
      end
    end
  end

  describe ".select_options" do
    it "returns inverted hash as array of arrays" do
      expected = [["None", :none], ["Closed", :closed], ["Duplicated", :duplicated]]
      expect(described_class.select_options).to eq(expected)
    end
  end

  describe "rendering" do
    context "with valid discard reason" do
      let(:discard_reason) { :closed }

      it "renders the correct text" do
        render_inline(component)
        expect(rendered_content).to have_text("Closed")
      end
    end

    context "with invalid discard reason" do
      let(:discard_reason) { :invalid }

      it "renders error message" do
        render_inline(component)
        expect(rendered_content).to have_text("Unsupported value 'invalid'")
      end
    end

    context "with string discard reason" do
      let(:discard_reason) { "none" }

      it "renders the correct text" do
        render_inline(component)
        expect(rendered_content).to have_text("None")
      end
    end
  end
end
