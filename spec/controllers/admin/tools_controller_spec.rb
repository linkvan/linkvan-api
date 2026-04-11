# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ToolsController do
  let(:admin_user) { create(:user, :admin, :verified) }
  let(:non_admin_user) { create(:user, :verified) }

  # Stub Devise authentication methods
  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: admin_user, user_signed_in?: true)
  end

  describe "DELETE #purge_facilities" do
    subject(:purge_facilities) { delete :purge_facilities, params: { api: api_key } }

    let(:api_key) { "drinking-fountains" }

    context "when admin user" do
      let(:drinking_fountains_key) { "drinking-fountains" }
      let(:public_washrooms_key) { "public-washrooms" }

      before do
        create(:facility, :with_verified, external_id: "FOO123", name: "Fountain 1")
        create(:facility, :with_verified, external_id: "BAR456", name: "Fountain 2")
      end

      context "with valid api_key" do
        it "purges all external facilities" do
          purge_facilities

          expect(Facility.external.kept.count).to eq(0)
        end

        it "redirects with notice showing count" do
          purge_facilities

          expect(response).to redirect_to(admin_facilities_path(service: "water_fountain"))
          expect(flash[:notice]).to include("2")
        end

        it "discards facilities with sync_removed reason" do
          purge_facilities

          discarded = Facility.external.with_discarded.find_by(external_id: "FOO123")
          expect(discarded).to be_discarded
          expect(discarded.discard_reason).to eq("sync_removed")
        end
      end

      context "with invalid api_key" do
        let(:api_key) { "invalid-api" }

        it "redirects with alert" do
          purge_facilities

          expect(response).to redirect_to(admin_tools_path)
          expect(flash[:alert]).to include("Invalid API")
        end
      end

      context "with no facilities to purge" do
        before do
          Facility.external.kept.destroy_all
        end

        it "redirects with notice showing zero count" do
          purge_facilities

          expect(response).to redirect_to(admin_facilities_path(service: "water_fountain"))
          expect(flash[:notice]).to include("0")
        end
      end
    end

    context "when non-admin user" do
      before do
        allow(controller).to receive_messages(current_user: non_admin_user, user_signed_in?: true)
      end

      it "redirects with access denied" do
        purge_facilities

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Access denied")
      end
    end
  end

  describe "GET #index" do
    subject(:get_index) { get :index }

    it { is_expected.to have_http_status(:success) }

    it "renders without error" do
      get_index
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #import_facilities" do
    subject(:import_facilities) { post :import_facilities, params: { api: api_key } }

    let(:api_key) { "drinking-fountains" }

    context "when admin user" do
      context "with valid api_key" do
        let(:syncer_result) do
          ApplicationService::Result.new(
            data: { facilities: [], total_count: 0, created_count: 0, updated_count: 0, deleted_count: 0, api_key: api_key },
            errors: []
          )
        end

        before do
          allow(External::VancouverCity::Syncer).to receive(:call)
            .and_return(syncer_result)
        end

        it "imports facilities and redirects" do
          import_facilities

          expect(response).to redirect_to(admin_facilities_path(service: "water_fountain"))
        end
      end

      context "with invalid api_key" do
        let(:api_key) { "invalid-api" }

        it "redirects with alert" do
          import_facilities

          expect(response).to redirect_to(admin_tools_path)
          expect(flash[:alert]).to include("Invalid API")
        end
      end
    end

    context "when non-admin user" do
      before do
        allow(controller).to receive_messages(current_user: non_admin_user, user_signed_in?: true)
      end

      it "redirects with access denied" do
        import_facilities

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Access denied")
      end
    end
  end
end
