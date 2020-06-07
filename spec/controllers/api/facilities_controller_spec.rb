require 'rails_helper'

RSpec.describe Api::FacilitiesController do
  let(:test_services) { 'Test AnotherTest Yet_Another_Test' }

  describe "GET #index" do
    before do
      @all_day_facility = create(:open_all_day_facility, services: test_services)
      get :index
    end

    let(:parsed_response) { JSON.parse(response.body).with_indifferent_access }

    subject { response }

    it { should have_http_status(:success) }

    it 'calls Facility.is_verified' do
      expect(Facility).to receive(:is_verified).and_call_original
      get :index
    end
    it 'uses Facilities::IndexFacilitySerializer class' do
      expect_any_instance_of(FacilitiesSerializer).to receive(:serialize).with(Facilities::IndexFacilitySerializer)
      get :index
    end
    it 'calls FacilitiesSerializer to_json' do
      expect_any_instance_of(FacilitiesSerializer).to receive(:to_json)
      get :index
    end

    describe "JSON body response" do
      subject { parsed_response }

      it { should include(:status) }
      it { should include(:facilities) }

      describe "facilities" do
        subject { parsed_response['facilities'] }

        it { should be_a(Array) }
      end
    end #/json body
  end #/index
end
