require "rails_helper"

RSpec.describe Api::FacilitiesController do # , type: :request do
  # let(:test_services) { "shelter legal" }

  describe "GET #index" do
    let(:all_day_facility) { create(:open_all_day_facility, :with_services) }
    before do
      all_day_facility

      get :index
    end

    let(:parsed_response) { JSON.parse(response.body).with_indifferent_access }

    subject { response }

    it { should have_http_status(:success) }

    it "calls Facility.is_verified" do
      expect(Facility).to receive(:is_verified).and_call_original
      get :index
    end

    it "calls Serializers" do
      expect_any_instance_of(FacilitySerializer).to receive(:call).and_call_original
      expect_any_instance_of(SiteStatsSerializer).to receive(:call).and_call_original
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
