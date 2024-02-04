require 'rails_helper'

describe Locations::GoogleMaps::StaticMapService do
  # BASE_URL = "https://maps.googleapis.com/maps/api/staticmap"
  subject(:map_service) { described_class.new(latitude, longitude) }

  let(:result) { map_service.call }

  let(:latitude) { 49.243463359535 }
  let(:longitude) { -123.106431021296 }

  let(:expected_center) do
    "center=#{coordinates}"
  end
  # escaped "|"
  let(:marker_separator) { "%7C" }
  # escaped ","
  let(:coordinates_separator) { "%2C" }

  let(:coordinates) do
    [latitude.round(6), longitude.round(6)].join(coordinates_separator)
  end
  let(:expected_markers) do
    # Ignoring configuration and only testing location
    "#{marker_separator}#{coordinates}"
  end

  it { expect(result).to be_a(URI::HTTPS) }
  it { expect(result.hostname).to eq("maps.googleapis.com") }
  it { expect(result.path).to eq("/maps/api/staticmap") }
  it { expect(result.scheme).to eq("https") }
  it { expect(result.query).to include(expected_center) }
  # Ignoring configuration and only testing location
  it { expect(result.query).to match(/markers=(.*)#{expected_markers}/) }
end
