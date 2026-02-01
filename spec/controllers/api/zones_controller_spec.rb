# frozen_string_literal: true

require "rails_helper"
require "support/shared_examples/api_tokens"

RSpec.describe Api::ZonesController do
  let(:zone) { create(:zone) }
  let(:zone_with_facilities) { create(:zone_with_facilities, facilities_count: 3) }
  let(:zone_with_users) { create(:zone_with_users, users_count: 2) }
  let(:super_admin) { create(:user, :admin, :verified) }
  let(:regular_user) { create(:user, :verified) }
  let(:non_admin_user) { create(:user, admin: false, verified: true) }

  before do
    config_jwt
  end

  describe "GET #index" do
    subject(:get_index) { get :index, params: request_params }

    let(:request_params) { {} }
    let(:load_data) { [zone, zone_with_facilities, zone_with_users] }
    let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }
    let(:returned_zones) { parsed_response[:zones] }

    before do
      load_data
      get_index
    end

    include_examples "api tokens"

    it { is_expected.to have_http_status(:success) }

    context "with zones having facilities and users" do
      it "returns all zones" do
        expect(returned_zones).to be_present
        expect(returned_zones.count).to eq(3)
      end

      describe "JSON body response" do
        it { expect(parsed_response).to include(:zones) }

        it "includes zone data" do
          expect(returned_zones.first).to include(
            id: zone.id,
            name: zone.name,
            description: zone.description
          )
        end

        it "includes facilities for each zone" do
          zone_data = returned_zones.find { |z| z[:id] == zone_with_facilities.id }
          expect(zone_data).to include(:facilities)
          expect(zone_data[:facilities]).to be_present
          expect(zone_data[:facilities].count).to eq(3)
        end

        it "includes users for each zone" do
          zone_data = returned_zones.find { |z| z[:id] == zone_with_users.id }
          expect(zone_data).to include(:users)
          expect(zone_data[:users]).to be_present
          expect(zone_data[:users].count).to eq(2)
        end
      end
    end

    context "with no zones" do
      let(:load_data) { nil }

      it { expect(returned_zones).to be_blank }
    end
  end

  describe "GET #list_admin" do
    subject(:get_list_admin) { get :list_admin, params: { id: zone.id } }

    let(:zone) { create(:zone_with_users, users_count: 3) }
    let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }
    let(:returned_users) { parsed_response[:users] }

    before do
      allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: super_admin)
      get_list_admin
    end

    it { expect(response).to have_http_status(:success) }

    it "returns zone admins" do
      expect(returned_users).to be_present
      expect(returned_users.count).to eq(3)
    end

    describe "JSON body response" do
      it { expect(parsed_response).to include(:users) }

      it "includes user data" do
        first_user = returned_users.first
        expect(first_user).to include(
          id: an_instance_of(Integer),
          name: an_instance_of(String),
          email: an_instance_of(String)
        )
      end
    end
  end

  describe "POST #add_admin" do
    subject(:post_add_admin) { post :add_admin, params: { id: zone.id, user_id: user.id } }

    let(:zone) { create(:zone) }
    let(:user) { create(:user, :verified) }
    let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }

    context "when user is authenticated admin" do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: super_admin)
      end

      context "with successful admin addition" do
        it { is_expected.to have_http_status(:created) }

        it "adds user to zone" do
          expect do
            post_add_admin
          end.to change(zone.users, :count).by(1)
        end

        it "returns zone data" do
          post_add_admin
          expect(parsed_response).to include(
            id: zone.id,
            name: zone.name,
            description: zone.description
          )
        end
      end

      context "when user is already a zone admin" do
        before do
          zone.users << user
        end

        it "returns conflict status" do
          expect(post_add_admin).to have_http_status(:conflict)
        end
      end
    end

    context "when user is not authenticated" do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: false)
      end

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context "when user is not an admin" do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: non_admin_user)
      end

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context "when zone does not exist" do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: super_admin)
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          post :add_admin, params: { id: 99_999, user_id: user.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when user does not exist" do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: super_admin)
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          post :add_admin, params: { id: zone.id, user_id: 99_999 }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE #remove_admin" do
    subject(:delete_remove_admin) { delete :remove_admin, params: { id: zone.id, user_id: user.id } }

    let(:zone) { create(:zone) }
    let(:user) { create(:user, :verified) }
    let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }

    before do
      zone.users << user
    end

    context "when user is authenticated admin" do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: super_admin)
      end

      context "with successful admin removal" do
        it { is_expected.to have_http_status(:ok) }

        it "removes user from zone" do
          expect do
            delete_remove_admin
          end.to change(zone.users, :count).by(-1)
        end

        it "returns zone data" do
          delete_remove_admin
          expect(parsed_response).to include(
            id: zone.id,
            name: zone.name,
            description: zone.description
          )
        end
      end

      context "when user is not a zone admin" do
        let(:other_user) { create(:user, :verified) }

        it "returns conflict status" do
          delete :remove_admin, params: { id: zone.id, user_id: other_user.id }
          expect(response).to have_http_status(:conflict)
        end
      end
    end

    context "when user is not authenticated" do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: false)
      end

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context "when user is not an admin" do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: non_admin_user)
      end

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context "when zone does not exist" do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: super_admin)
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          delete :remove_admin, params: { id: 99_999, user_id: user.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when user does not exist" do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: super_admin)
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          delete :remove_admin, params: { id: zone.id, user_id: 99_999 }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "authorization" do
    let(:zone) { create(:zone) }

    context "list_admin action" do
      context "when user is not authenticated" do
        before do
          allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: false)
        end

        it "returns unauthorized status" do
          get :list_admin, params: { id: zone.id }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when user is authenticated but not an admin" do
        before do
          allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: non_admin_user)
        end

        it "returns unauthorized status" do
          get :list_admin, params: { id: zone.id }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "add_admin action" do
      context "when user is not authenticated" do
        before do
          allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: false)
        end

        it "returns unauthorized status" do
          post :add_admin, params: { id: zone.id, user_id: 1 }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when user is authenticated but not an admin" do
        before do
          allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: non_admin_user)
        end

        it "returns unauthorized status" do
          post :add_admin, params: { id: zone.id, user_id: 1 }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "remove_admin action" do
      context "when user is not authenticated" do
        before do
          allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: false)
        end

        it "returns unauthorized status" do
          delete :remove_admin, params: { id: zone.id, user_id: 1 }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when user is authenticated but not an admin" do
        before do
          allow(controller).to receive_messages(authenticate_user!: true, user_signed_in?: true, current_user: non_admin_user)
        end

        it "returns unauthorized status" do
          delete :remove_admin, params: { id: zone.id, user_id: 1 }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
