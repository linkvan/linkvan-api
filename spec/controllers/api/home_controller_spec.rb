require "rails_helper"

RSpec.shared_examples :includes_site_status do
  subject(:returned_site_status) { parsed_response.fetch(:site_stats) }

  let(:site_stats) { SiteStats.new }
  let(:facility) { create(:facility) }
  let(:notice) { create(:notice) }
  let(:load_data) { [facility, notice, site_stats] }
  let(:last_updated) { site_stats.last_updated.as_json }

  describe "last_updated" do
    it { expect(returned_site_status.fetch(:last_updated)).to eq(last_updated) }
  end
end

RSpec.describe Api::HomeController do
  before do
    load_data
  end

  describe "GET #index" do
    subject(:perform_request) { get :index, params: request_params }

    let(:load_data) { nil }
    let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }
    let(:returned_notices) { parsed_response[:notices] }
    let(:request_params) { {} }

    describe "request headers" do
      before do
        request_headers.each_pair do |key, value|
          request.headers[key] = value
        end
      end

      context "without User-Location header" do
        let(:request_headers) { {} }

        before do
          perform_request
        end

        it_behaves_like :includes_site_status

        it { expect(perform_request).to have_http_status(:success) }
      end

      context "with User-Location header" do
        context "with a string value" do
          let(:request_headers) { { "User-Location" => '{"lat":1.01, "lng":0.4 }' } }

          it { expect(perform_request).to have_http_status(:success) }
          it { expect { perform_request }.to change(Analytics::Event, :count).by(1) }

          describe "created event" do
            let(:created_event) { Analytics::Event.last }

            before do
              perform_request
              created_event
            end

            it { expect(created_event.lat).to eq(1.01) }
            it { expect(created_event.long).to eq(0.4) }
          end
        end

        context "with a string with a value of null value" do
          let(:request_headers) { { "User-Location" => "null" } }

          it { expect(perform_request).to have_http_status(:success) }
          it { expect { perform_request }.to change(Analytics::Event, :count).by(1) }

          describe "created event" do
            let(:created_event) { Analytics::Event.last }

            before do
              perform_request
              created_event
            end

            it { expect(created_event.lat).to eq(nil) }
            it { expect(created_event.long).to eq(nil) }
          end
        end

        context "with a hash value" do
          let(:request_headers) { { "User-Location" => { lat: 1.01, lng: 0.4 } } }

          it { expect(perform_request).to have_http_status(:success) }
          it { expect { perform_request }.to change(Analytics::Event, :count).by(1) }

          describe "created event" do
            let(:created_event) { Analytics::Event.last }

            before do
              perform_request
              created_event
            end

            it { expect(created_event.lat).to eq(1.01) }
            it { expect(created_event.long).to eq(0.4) }
          end
        end

        context "with a nil value" do
          let(:request_headers) { { "User-Location" => nil } }

          it { expect(perform_request).to have_http_status(:success) }
          it { expect { perform_request }.to change(Analytics::Event, :count).by(1) }

          describe "created event" do
            let(:created_event) { Analytics::Event.last }

            before do
              perform_request
              created_event
            end

            it { expect(created_event.lat).to eq(nil) }
            it { expect(created_event.long).to eq(nil) }
          end
        end

        context "with an invalid json" do
          let(:request_headers) { { "User-Location" => "{ null" } }

          it { expect(perform_request).to have_http_status(:success) }
          it { expect { perform_request }.to change(Analytics::Event, :count).by(1) }

          describe "created event" do
            let(:created_event) { Analytics::Event.last }

            before do
              perform_request
              created_event
            end

            it { expect(created_event.lat).to eq(nil) }
            it { expect(created_event.long).to eq(nil) }
          end
        end
      end
    end
  end
end
