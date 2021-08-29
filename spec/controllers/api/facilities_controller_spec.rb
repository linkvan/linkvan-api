require "rails_helper"

RSpec.describe Api::FacilitiesController do # , type: :request do
  let(:test_services) { "shelter legal" }

  describe "GET #index" do
    before do
      @all_day_facility = create(:open_all_day_facility, services: test_services)
      get :index
    end

    let(:parsed_response) { JSON.parse(response.body).with_indifferent_access }

    subject { response }

    it { should have_http_status(:success) }

    it "calls Facility.is_verified" do
      expect(Facility).to receive(:is_verified).and_call_original
      get :index
    end
    it "uses Facilities::IndexFacilitySerializer class" do
      expect_any_instance_of(FacilitiesSerializer).to receive(:serialize).with(Facilities::IndexFacilitySerializer)
      get :index
    end
    it "calls FacilitiesSerializer to_json" do
      expect_any_instance_of(FacilitiesSerializer).to receive(:to_json)
      get :index
    end

    describe "JSON body response" do
      let(:returned_facilities) { parsed_response["facilities"] }

      it { expect(response.status).to eq(200) }
      it { expect(parsed_response).to include(:facilities) }
      it { expect(returned_facilities).to be_a(Array) }
    end
  end
end
