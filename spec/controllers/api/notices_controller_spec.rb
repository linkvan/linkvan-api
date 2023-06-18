require "rails_helper"

RSpec.describe Api::NoticesController do
  before do
    load_data
  end

  describe "GET #index" do
    let(:load_data) { nil }
    let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }
    let(:returned_notices) { parsed_response[:notices] }
    let(:request_params) { {} }

    before do
      get :index, params: request_params
    end

    it { expect(response).to have_http_status(:success) }

    context "when no parameters is provided" do
      let(:request_params) { {} }

      context "with published notices" do
        let(:notice) { create(:notice, :published) }
        let(:load_data) { notice }

        it { expect(returned_notices).to be_present }

        describe "notice json" do
          let(:notice_json) { returned_notices.first }

          it { expect(notice_json).to include(id: notice.id) }
          it { expect(notice_json).to include(title: notice.title) }
          it { expect(notice_json).to include(notice_type: notice.notice_type) }
          it { expect(notice_json).to include(published: true) }
          it { expect(notice_json).to include(slug: notice.slug) }
        end
      end

      context "with draft notices" do
        let(:load_data) { create(:notice, :draft) }

        it { expect(returned_notices).to be_blank }
      end
    end
  end
end
