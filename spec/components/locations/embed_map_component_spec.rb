# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::EmbedMapComponent, type: :component do
  subject(:component) { described_class.new(lat, long, **options) }

  let(:lat) { 49.2827 }
  let(:long) { -123.1207 }
  let(:options) { {} }
  let(:mock_url) { "https://maps.googleapis.com/maps/embed/v1/place?center=49.2827,-123.1207&zoom=14&maptype=roadmap&q=49.2827,-123.1207&key=test_key" }

  before do
    allow(Locations::GoogleMaps::EmbedMapService).to receive(:call).and_return(mock_url)
  end

  describe "initialization" do
    it "initializes with latitude and longitude" do
      expect(component.instance_variable_get(:@lat)).to eq(lat)
      expect(component.instance_variable_get(:@long)).to eq(long)
    end

    it "merges options with default CONFIG" do
      default_options = {
        width: "100%",
        height: "400",
        style: "border:0",
        frameborder: "0",
        referrerpolicy: "no-referrer-when-downgrade"
      }

      expect(component.options).to include(default_options)
    end

    context "with custom options" do
      let(:options) { { width: "50%", height: "200", custom_attr: "value" } }

      it "overrides default options" do
        expect(component.options[:width]).to eq("50%")
        expect(component.options[:height]).to eq("200")
      end

      it "adds custom options" do
        expect(component.options[:custom_attr]).to eq("value")
      end

      it "preserves default options not overridden" do
        expect(component.options[:style]).to eq("border:0")
        expect(component.options[:frameborder]).to eq("0")
      end
    end
  end

  describe "#render?" do
    context "when both lat and long are present" do
      it "returns true" do
        expect(component.render?).to be true
      end
    end

    context "when lat is nil" do
      let(:lat) { nil }

      it "returns false" do
        expect(component.render?).to be false
      end
    end

    context "when long is nil" do
      let(:long) { nil }

      it "returns false" do
        expect(component.render?).to be false
      end
    end

    context "when both lat and long are nil" do
      let(:lat) { nil }
      let(:long) { nil }

      it "returns false" do
        expect(component.render?).to be false
      end
    end

    context "when lat is empty string" do
      let(:lat) { "" }

      it "returns false" do
        expect(component.render?).to be false
      end
    end

    context "when long is empty string" do
      let(:long) { "" }

      it "returns false" do
        expect(component.render?).to be false
      end
    end
  end

  describe "rendering" do
    context "when render? is true" do
      it "renders successfully" do
        expect { render_inline(component) }.not_to raise_exception
      end

      it "renders an iframe element" do
        render_inline(component)

        expect(rendered_content).to have_css("iframe")
      end

      it "sets the correct src attribute" do
        render_inline(component)

        expect(rendered_content).to have_css("iframe[src='#{mock_url}']")
      end

      it "sets default iframe attributes" do
        render_inline(component)

        expect(rendered_content).to have_css("iframe[width='100%']")
        expect(rendered_content).to have_css("iframe[height='400']")
        expect(rendered_content).to have_css("iframe[style='border:0']")
        expect(rendered_content).to have_css("iframe[frameborder='0']")
        expect(rendered_content).to have_css("iframe[referrerpolicy='no-referrer-when-downgrade']")
      end

      it "calls the EmbedMapService with correct coordinates" do
        render_inline(component)

        expect(Locations::GoogleMaps::EmbedMapService).to have_received(:call).with(lat, long)
      end
    end

    context "when render? is false" do
      let(:lat) { nil }

      it "renders nothing" do
        render_inline(component)

        expect(rendered_content.strip).to be_empty
      end
    end

    context "with custom options" do
      let(:options) { { width: "800", height: "600", loading: "lazy", title: "Map" } }

      it "includes custom attributes in iframe" do
        render_inline(component)

        expect(rendered_content).to have_css("iframe[width='800']")
        expect(rendered_content).to have_css("iframe[height='600']")
        expect(rendered_content).to have_css("iframe[loading='lazy']")
        expect(rendered_content).to have_css("iframe[title='Map']")
      end
    end
  end

  describe "edge cases" do
    context "with zero coordinates" do
      let(:lat) { 0 }
      let(:long) { 0 }

      it "renders successfully" do
        expect { render_inline(component) }.not_to raise_exception
      end

      it "calls the service with zero coordinates" do
        render_inline(component)

        expect(Locations::GoogleMaps::EmbedMapService).to have_received(:call).with(0, 0)
      end
    end

    context "with negative coordinates" do
      let(:lat) { -49.2827 }
      let(:long) { 123.1207 }

      it "renders successfully" do
        expect { render_inline(component) }.not_to raise_exception
      end

      it "calls the service with negative coordinates" do
        render_inline(component)

        expect(Locations::GoogleMaps::EmbedMapService).to have_received(:call).with(-49.2827, 123.1207)
      end
    end

    context "with string coordinates" do
      let(:lat) { "49.2827" }
      let(:long) { "-123.1207" }

      it "renders successfully" do
        expect { render_inline(component) }.not_to raise_exception
      end

      it "calls the service with string coordinates" do
        render_inline(component)

        expect(Locations::GoogleMaps::EmbedMapService).to have_received(:call).with("49.2827", "-123.1207")
      end
    end
  end

  describe "service integration" do
    context "when service returns a URI object" do
      let(:mock_uri) { URI.parse(mock_url) }

      before do
        allow(Locations::GoogleMaps::EmbedMapService).to receive(:call).and_return(mock_uri)
      end

      it "converts URI to string for src attribute" do
        render_inline(component)

        expect(rendered_content).to have_css("iframe[src='#{mock_url}']")
      end
    end

    context "when service raises an error" do
      before do
        allow(Locations::GoogleMaps::EmbedMapService).to receive(:call).and_raise(StandardError.new("API Error"))
      end

      it "propagates the error" do
        expect { render_inline(component) }.to raise_error(StandardError, "API Error")
      end
    end
  end

  describe "HTML structure" do
    it "produces valid HTML" do
      render_inline(component)

      # Basic structure check
      expect(rendered_content).to include("<iframe")
      expect(rendered_content).to include("</iframe>")
    end

    it "includes all necessary attributes" do
      render_inline(component)

      expect(rendered_content).to include("src=")
      expect(rendered_content).to include("width=")
      expect(rendered_content).to include("height=")
      expect(rendered_content).to include("style=")
      expect(rendered_content).to include("frameborder=")
      expect(rendered_content).to include("referrerpolicy=")
    end
  end
end
