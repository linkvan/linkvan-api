require "rails_helper"
require 'support/shared_examples/api_tokens'

RSpec.describe Api::FacilitiesController do # , type: :request do
  let(:verified_facility) { create(:open_all_day_facility, :with_services, verified: true) }
  let(:nonverified_facility) { create(:open_all_day_facility, :with_services, verified: false) }

  before do
    config_jwt
    load_data
  end

  # TODO: Enable tests when analytics feature is re-enabled.
  xdescribe "analytics data" do
    context "without facilities" do
      let(:load_data) { nonverified_facility }

      it "adds analytics data for the request without any impressions" do
        expect do
          get :index, params: {}
        end.to change(Analytics::Visit, :count).by(1)
          .and change(Analytics::Event, :count).by(1)
          .and not_change(Analytics::Impression, :count)
      end
    end

    context "with facilities" do
      let(:load_data) { [verified_facility, nonverified_facility, another_verified_facility] }
      let(:another_verified_facility) { create(:open_all_day_facility, :with_services, verified: true) }

      it "adds analytics data for the request with both verified facilities" do
        expect do
          get :index, params: {}
        end.to change(Analytics::Visit, :count).by(1)
          .and change(Analytics::Event, :count).by(1)
          .and change(Analytics::Impression, :count).by(2)

        saved_event = Analytics::Event.last

        expect(saved_event.facilities).to include(verified_facility, another_verified_facility)
        expect(saved_event.facilities).not_to include(nonverified_facility)
      end
    end

    context "with duplicated facilities" do
      let(:load_data) { [verified_facility, verified_facility] }

      it "adds analytics data for the request with the duplicated facility onlhy once" do
        expect do
          get :index, params: {}
        end.to change(Analytics::Visit, :count).by(1)
          .and change(Analytics::Event, :count).by(1)
          .and change(Analytics::Impression, :count).by(1)

        saved_event = Analytics::Event.last

        expect(saved_event.facilities).to include(verified_facility).once
      end
    end
  end

  describe "GET #index" do
    subject { response }

    let(:load_data) { nil }
    let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }
    let(:returned_facilities) { parsed_response[:facilities] }
    let(:request_params) { {} }

    before do
      get :index, params: request_params
    end

    include_examples :api_tokens

    it { is_expected.to have_http_status(:success) }

    context "when no parameters is provided" do
      let(:load_data) { verified_facility }

      it { expect(returned_facilities).to be_blank }
    end

    context "when service parameter is included" do
      let(:request_params) { { service: "a_service" } }

      context "with facilities matching service by key" do
        let(:load_data) do
          verified_facility.services.first.update!(key: "a_service")
        end

        it { expect(returned_facilities).to be_present }
      end

      context "with facilities matching service by name" do
        let(:load_data) do
          verified_facility.services.first.update!(key: "another_service", name: "a_service")
        end

        it { expect(returned_facilities).to be_present }
      end

      context "without facilities matching service" do
        let(:load_data) do
          verified_facility.services.first.update!(key: "another_service")
        end

        it { expect(returned_facilities).to be_blank }
      end
    end

    context "when search parameter is included" do
      let(:request_params) { { search: "a_search_value" } }

      context "with facilities matching name" do
        let(:load_data) { verified_facility.update!(name: "a_search_value") }

        it { expect(returned_facilities).to be_present }
      end

      context "with facilities matching welcomes case insensitive" do
        let(:request_params) { { search: "Male" } }
        let(:load_data) do
          create(:facility_welcome, facility: verified_facility, customer: "male")
        end

        it { expect(returned_facilities).to be_present }
      end

      context "without facilities matching welcomes" do
        let(:request_params) { { search: "female" } }
        let(:load_data) do
          create(:facility_welcome, facility: verified_facility, customer: "male")
        end

        it { expect(returned_facilities).to be_blank }
      end

      context "without matching facilities" do
        let(:load_data) { verified_facility }

        it { expect(returned_facilities).to be_blank }
      end
    end

    describe "JSON body response" do
      let(:request_params) { { service: verified_facility.services.first.key } }

      let(:load_data) { verified_facility }
      let(:facility_content) { returned_facilities.first }
      let(:services_content) { facility_content[:services] }
      let(:site_stats_content) { parsed_response[:site_stats] }

      it { expect(parsed_response).to include(:facilities) }

      it do
        expect(returned_facilities).to contain_exactly(
          a_hash_including(id: verified_facility.id,
                           name: verified_facility.name,
                           lat: verified_facility.lat.to_s,
                           long: verified_facility.long.to_s)
        )
      end

      it do
        facility_service = verified_facility.facility_services.first
        service = facility_service.service
        expect(services_content).to contain_exactly(
          a_hash_including(key: service.key,
                           name: service.name,
                           note: facility_service.note)
        )
      end

      it do
        expect(site_stats_content).to match(
          a_hash_including(last_updated: verified_facility.updated_at.as_json)
        )
      end
    end
  end
end
