require "rails_helper"

RSpec.describe "Facilities index" do

  before do
    config_jwt
  end

  it "returns a json object" do
    visit api_facilities_path

    expect(page.status_code).to be(200)
    # expect(page).to have_text("Hello#index")
  end
end
