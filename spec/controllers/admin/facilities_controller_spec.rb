# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::FacilitiesController do
  let(:admin_user) { create(:user, :admin, :verified) }
  let(:non_admin_user) { create(:user, :verified) }

  # Stub Devise authentication methods
  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(admin_user)
    allow(controller).to receive(:user_signed_in?).and_return(true)
  end

  describe "GET #index" do
    subject(:get_index) { get :index, params: params }

    let(:params) { {} }

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before do
        create(:facility)
        get_index
      end

      it { expect(assigns(:facilities)).to be_present }
      it { expect(assigns(:pagy)).to be_a(Pagy) }
      it { expect(assigns(:services_dropdown)).to be_present }
      it { expect(assigns(:welcomes_dropdown)).to be_present }
    end

    describe "pagination" do
      context "with many facilities" do
        let(:params) { { page: 1 } }
        let(:facilities) { create_list(:facility, 25) }

        before { facilities && get_index }

        it "paginates facilities" do
          expect(assigns(:facilities).count).to be <= 20
          expect(assigns(:pagy).limit).to eq(20)
        end
      end
    end

    describe "filtering by status" do
      let(:live_facility) { create(:facility, :with_verified) }
      let(:pending_facility) { create(:facility, verified: false) }
      let(:discarded_facility) { create(:facility).tap(&:discard) }

      context "with status: live" do
        let(:params) { { status: "live" } }

        before { live_facility && pending_facility && discarded_facility && get_index }

        it { expect(assigns(:facilities)).to include(live_facility) }
        it { expect(assigns(:facilities)).not_to include(pending_facility) }
        it { expect(assigns(:facilities)).not_to include(discarded_facility) }
      end

      context "with status: pending_reviews" do
        let(:params) { { status: "pending_reviews" } }

        before { live_facility && pending_facility && discarded_facility && get_index }

        it { expect(assigns(:facilities)).not_to include(live_facility) }
        it { expect(assigns(:facilities)).to include(pending_facility) }
        it { expect(assigns(:facilities)).not_to include(discarded_facility) }
      end

      context "with status: discarded" do
        let(:params) { { status: "discarded" } }

        before { live_facility && pending_facility && discarded_facility && get_index }

        it { expect(assigns(:facilities)).not_to include(live_facility) }
        it { expect(assigns(:facilities)).not_to include(pending_facility) }
        it { expect(assigns(:facilities)).to include(discarded_facility) }
      end
    end

    describe "filtering by service" do
      let(:service) { create(:service, key: "water_fountain", name: "Water Fountain") }
      let(:facility_with_service) { create(:facility).tap { |f| f.services << service } }
      let(:facility_without_service) { create(:facility) }

      context "with service: key" do
        let(:params) { { service: "water_fountain" } }

        before { facility_with_service && facility_without_service && get_index }

        it { expect(assigns(:facilities)).to include(facility_with_service) }
        it { expect(assigns(:facilities)).not_to include(facility_without_service) }
      end

      context "with service: name" do
        let(:params) { { service: "Water Fountain" } }

        before { facility_with_service && facility_without_service && get_index }

        it { expect(assigns(:facilities)).to include(facility_with_service) }
        it { expect(assigns(:facilities)).not_to include(facility_without_service) }
      end

      context "with service: none" do
        let(:params) { { service: "none" } }

        before { facility_with_service && facility_without_service && get_index }

        it { expect(assigns(:facilities)).not_to include(facility_with_service) }
        it { expect(assigns(:facilities)).to include(facility_without_service) }
      end
    end

    describe "filtering by welcome_customer" do
      let(:facility_with_male_welcome) { create(:facility) }
      let(:facility_without_welcome) { create(:facility) }

      before do
        create(:facility_welcome, facility: facility_with_male_welcome, customer: :male)
      end

      context "with welcome_customer: male" do
        let(:params) { { welcome_customer: "male" } }

        before { facility_with_male_welcome && facility_without_welcome && get_index }

        it { expect(assigns(:facilities)).to include(facility_with_male_welcome) }
        it { expect(assigns(:facilities)).not_to include(facility_without_welcome) }
      end

      context "with welcome_customer: none" do
        let(:params) { { welcome_customer: "none" } }

        before { facility_with_male_welcome && facility_without_welcome && get_index }

        it { expect(assigns(:facilities)).not_to include(facility_with_male_welcome) }
        it { expect(assigns(:facilities)).to include(facility_without_welcome) }
      end
    end

    describe "search query" do
      let(:facility_by_name) { create(:facility, name: "Downtown Center") }
      let(:facility_by_address) { create(:facility, address: "123 Main Street") }
      let(:other_facility) { create(:facility, name: "Uptown Clinic", address: "456 Oak Ave") }

      before { facility_by_name && facility_by_address && other_facility && get_index }

      context "with search matching name" do
        let(:params) { { q: "Downtown" } }

        it { expect(assigns(:facilities)).to include(facility_by_name) }
        it { expect(assigns(:facilities)).not_to include(facility_by_address) }
        it { expect(assigns(:facilities)).not_to include(other_facility) }
      end

      context "with search matching address" do
        let(:params) { { q: "Main" } }

        it { expect(assigns(:facilities)).not_to include(facility_by_name) }
        it { expect(assigns(:facilities)).to include(facility_by_address) }
        it { expect(assigns(:facilities)).not_to include(other_facility) }
      end

      context "with search matching partial text" do
        let(:params) { { q: "center" } }

        it { expect(assigns(:facilities)).to include(facility_by_name) }
        it { expect(assigns(:facilities)).not_to include(facility_by_address) }
        it { expect(assigns(:facilities)).not_to include(other_facility) }
      end
    end

    describe "dropdown data" do
      before { create(:service, name: "Water Fountain", key: "water_fountain") && get_index }

      it "includes 'No Services' option" do
        expect(assigns(:services_dropdown)).to include(["No Services", :none])
      end

      it "includes service names and keys" do
        expect(assigns(:services_dropdown)).to include(["Water Fountain", "water_fountain"])
      end
    end
  end

  describe "GET #show" do
    let(:facility) { create(:facility) }

    it "returns success" do
      get :show, params: { id: facility.id }
      expect(response).to have_http_status(:success)
    end

    describe "assigns" do
      before { get :show, params: { id: facility.id } }

      it { expect(assigns(:facility)).to eq(facility) }
    end

    context "when facility does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { get :show, params: { id: -1 } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET #new" do
    subject(:get_new) { get :new }

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before { get_new }

      it { expect(assigns(:facility)).to be_a_new(Facility) }
      it { expect(assigns(:facility).zone).to eq(admin_user.zones.first) }
    end

    context "when user has no zones" do
      let(:admin_user) { create(:user, :admin, :verified, zones: []) }

      before { get_new }

      it { is_expected.to have_http_status(:success) }
      it { expect(assigns(:facility).zone).to be_nil }
    end
  end

  describe "GET #edit" do
    let(:facility) { create(:facility) }

    it "returns success" do
      get :edit, params: { id: facility.id }
      expect(response).to have_http_status(:success)
    end

    describe "assigns" do
      before { get :edit, params: { id: facility.id } }

      it { expect(assigns(:facility)).to eq(facility) }
    end

    context "when facility does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { get :edit, params: { id: -1 } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST #create" do
    subject(:post_create) { post :create, params: params }

    let(:params) { { facility: facility_attributes } }
    let(:facility_attributes) do
      {
        name: "New Facility",
        phone: "555-1234",
        website: "https://newfacility.test",
        notes: "Test notes"
      }
    end

    it { is_expected.to have_http_status(:redirect) }

    describe "creates a new facility" do
      it { expect { post_create }.to change(Facility, :count).by(1) }

      context "with valid attributes" do
        it "redirects to show" do
          post_create
          expect(response).to redirect_to(admin_facility_path(assigns(:facility)))
        end

        it "sets flash notice" do
          post_create
          expect(flash[:notice]).to match(/Successfully created facility/)
        end
      end
    end

    context "with invalid attributes" do
      let(:facility_attributes) { { name: nil } }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not create a facility" do
        expect { post_create }.not_to change(Facility, :count)
      end

      it "sets flash alert" do
        post_create
        expect(flash[:alert]).to match(/Failed to create facility/)
      end

      it "renders new template" do
        post_create
        expect(response).to render_template(:new)
      end
    end

    describe "facility association" do
      before { post_create }

      it { expect(assigns(:facility).user).to eq(admin_user) }
    end
  end

  describe "PATCH #update" do
    subject(:patch_update) { patch :update, params: params }

    let(:facility) { create(:facility, name: "Original Name") }
    let(:params) { { id: facility.id, facility: { name: "Updated Name" } } }

    it { is_expected.to have_http_status(:redirect) }

    context "with valid attributes" do
      it "updates the facility" do
        patch_update
        expect(facility.reload.name).to eq("Updated Name")
      end

      it "redirects to show" do
        patch_update
        expect(response).to redirect_to(admin_facility_path(facility))
      end

      it "sets flash notice" do
        patch_update
        expect(flash[:notice]).to match(/Successfully updated facility/)
      end
    end

    context "with invalid attributes" do
      let(:params) { { id: facility.id, facility: { name: nil } } }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not update the facility" do
        patch_update
        expect(facility.reload.name).to eq("Original Name")
      end

      it "sets flash alert" do
        patch_update
        expect(flash[:alert]).to match(/Failed to update facility/)
      end

      it "renders edit template" do
        patch_update
        expect(response).to render_template(:edit)
      end
    end

    describe "undiscard action" do
      let(:facility) { create(:facility).tap(&:discard) }
      let(:params) { { id: facility.id, undiscard: true } }

      context "when undiscard succeeds" do
        before do
          facility.discard_reason = :closed
          patch_update
        end

        it "undiscards the facility" do
          expect(facility.reload).not_to be_discarded
        end

        it "redirects to show" do
          expect(response).to redirect_to(admin_facility_path(facility))
        end

        it "sets flash notice" do
          expect(flash[:notice]).to match(/Successfully undiscarded facility/)
        end
      end

      context "when undiscard fails" do
        before do
          # Stub Facility.find to return the facility with the undiscard stub
          allow(Facility).to receive(:find).and_return(facility)
          allow(facility).to receive(:undiscard).and_return(false)
          facility.discard_reason = :closed
          patch_update
        end

        it "redirects to show" do
          expect(response).to redirect_to(admin_facility_path(facility))
        end

        it "sets flash notice with error" do
          expect(flash[:notice]).to match(/Failed to undiscarded facility/)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    subject(:delete_destroy) { delete :destroy, params: { id: facility.id, facility: { discard_reason: } } }

    let(:facility) { create(:facility) }
    let(:discard_reason) { "closed" }

    it { is_expected.to have_http_status(:redirect) }

    context "with valid discard reason" do
      it "discards the facility" do
        delete_destroy
        expect(facility.reload).to be_discarded
      end

      it "sets flash notice" do
        delete_destroy
        expect(flash[:notice]).to match(/Successfully discarded Facility/)
      end

      it "redirects back" do
        delete_destroy
        expect(response).to redirect_to(admin_facility_path(facility))
      end
    end

    context "when discard fails" do
      before do
        # Stub Facility.find to return the facility with the discard stub
        allow(Facility).to receive(:find).and_return(facility)
        allow(facility).to receive(:discard).and_return(false)
        delete_destroy
      end

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not discard the facility" do
        expect(facility.reload).not_to be_discarded
      end

      it "sets flash alert" do
        expect(flash[:alert]).to match(/Failed to discard Facility/)
      end

      it "renders show template" do
        expect(response).to render_template(:show)
      end
    end

    context "with duplicated reason" do
      let(:discard_reason) { "duplicated" }

      before { delete_destroy }

      it { expect(facility.reload.discard_reason).to eq("duplicated") }
    end
  end

  describe "PATCH #switch_status" do
    subject(:patch_switch) { patch :switch_status, params: { id: facility.id, status: } }

    let(:facility) { create(:facility, verified: false, lat: 49.2827, long: -123.1207) }
    let(:status) { "live" }

    it { is_expected.to have_http_status(:redirect) }

    context "switching to live" do
      before { patch_switch }

      it "verifies the facility" do
        expect(facility.reload).to be_verified
      end

      it "sets flash notice" do
        expect(flash[:notice]).to match(/Successfully switched Facility.*status to live/)
      end
    end

    context "switching to pending_reviews" do
      let(:status) { "pending_reviews" }
      let(:facility) { create(:facility, verified: true, lat: 49.2827, long: -123.1207) }

      before do
        facility.update(verified: true)
        patch_switch
      end

      it "unverifies the facility" do
        expect(facility.reload).not_to be_verified
      end

      it "sets flash notice" do
        expect(flash[:notice]).to match(/Successfully switched Facility.*status to pending_reviews/)
      end
    end

    context "when status update fails" do
      before do
        # Stub Facility.find to return the facility with the update_status stub
        allow(Facility).to receive(:find).and_return(facility)
        allow(facility).to receive(:update_status).and_return(false)
        patch_switch
      end

      it "sets flash alert" do
        expect(flash[:alert]).to match(/Failed to discard Facility/)
      end
    end
  end

  describe "before_action callbacks" do
    describe "#load_facility" do
      context "for show action" do
        let(:facility) { create(:facility) }

        before { get :show, params: { id: facility.id } }

        it { expect(assigns(:facility)).to eq(facility) }
      end

      context "for edit action" do
        let(:facility) { create(:facility) }

        before { get :edit, params: { id: facility.id } }

        it { expect(assigns(:facility)).to eq(facility) }
      end

      context "for update action" do
        let(:facility) { create(:facility) }

        before { patch :update, params: { id: facility.id, facility: { name: "New" } } }

        it { expect(assigns(:facility)).to eq(facility) }
      end

      context "for destroy action" do
        let(:facility) { create(:facility) }

        before { delete :destroy, params: { id: facility.id, facility: { discard_reason: "closed" } } }

        it { expect(assigns(:facility)).to eq(facility) }
      end

      context "for switch_status action" do
        let(:facility) { create(:facility) }

        before { patch :switch_status, params: { id: facility.id, status: "live" } }

        it { expect(assigns(:facility)).to eq(facility) }
      end

      context "when facility not found" do
        it "raises ActiveRecord::RecordNotFound" do
          expect { get :show, params: { id: -1 } }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "#load_facilities" do
      context "when facilities exist" do
        before do
          create(:facility)
          get :index
        end

        it "sets @facilities" do
          expect(assigns(:facilities)).to be_present
        end

        it "sets @pagy" do
          expect(assigns(:pagy)).to be_a(Pagy)
        end
      end
    end
  end

  describe "flash messages" do
    describe "create success" do
      before { post :create, params: { facility: { name: "Test", phone: "123" } } }

      it { expect(flash[:notice]).to match(/Successfully created facility/) }
      it { expect(flash[:notice]).to include("(id: #{assigns(:facility).id})") }
    end

    describe "update success" do
      let(:facility) { create(:facility) }

      before { patch :update, params: { id: facility.id, facility: { name: "Updated" } } }

      it { expect(flash[:notice]).to match(/Successfully updated facility/) }
      it { expect(flash[:notice]).to include("(id: #{facility.id})") }
    end

    describe "discard success" do
      let(:facility) { create(:facility) }

      before { delete :destroy, params: { id: facility.id, facility: { discard_reason: "closed" } } }

      it { expect(flash[:notice]).to match(/Successfully discarded Facility/) }
      it { expect(flash[:notice]).to include(facility.name) }
      it { expect(flash[:notice]).to include("(id: #{facility.id})") }
    end

    describe "switch_status success" do
      let(:facility) { create(:facility, verified: false, lat: 49.2827, long: -123.1207) }

      before { patch :switch_status, params: { id: facility.id, status: "live" } }

      it { expect(flash[:notice]).to match(/Successfully switched Facility/) }
      it { expect(flash[:notice]).to include(facility.name) }
      it { expect(flash[:notice]).to include("status to live") }
    end

    describe "undiscard success" do
      let(:facility) { create(:facility).tap(&:discard) }

      before { patch :update, params: { id: facility.id, undiscard: true } }

      it { expect(flash[:notice]).to match(/Successfully undiscarded facility/) }
    end

    describe "create failure" do
      before { post :create, params: { facility: { name: nil } } }

      it { expect(flash[:alert]).to match(/Failed to create facility/) }
      it { expect(flash[:alert]).to include("Errors:") }
    end

    describe "update failure" do
      let(:facility) { create(:facility) }

      before { patch :update, params: { id: facility.id, facility: { name: nil } } }

      it { expect(flash[:alert]).to match(/Failed to update facility/) }
      it { expect(flash[:alert]).to include("(id: #{facility.id})") }
    end

    describe "discard failure" do
      let(:facility) { create(:facility) }

      before do
        # Stub Facility.find to return the facility with the discard stub
        allow(Facility).to receive(:find).and_return(facility)
        allow(facility).to receive(:discard).and_return(false)
        delete :destroy, params: { id: facility.id, facility: { discard_reason: "closed" } }
      end

      it { expect(flash[:alert]).to match(/Failed to discard Facility/) }
      it { expect(flash[:alert]).to include(facility.name) }
      it { expect(flash[:alert]).to include("Errors:") }
    end

    describe "switch_status failure" do
      let(:facility) { create(:facility, verified: false) }

      before do
        # Stub Facility.find to return the facility with the update_status stub
        allow(Facility).to receive(:find).and_return(facility)
        allow(facility).to receive(:update_status).and_return(false)
        patch :switch_status, params: { id: facility.id, status: "live" }
      end

      it { expect(flash[:alert]).to match(/Failed to discard Facility/) }
      it { expect(flash[:alert]).to include(facility.name) }
      it { expect(flash[:alert]).to include("Errors:") }
    end
  end

  describe "parameter filtering" do
    describe "strong parameters for facility" do
      let(:facility) { create(:facility) }

      before do
        patch :update, params: {
          id: facility.id,
          facility: {
            verified: true,
            name: "Test",
            phone: "123",
            website: "https://test.com",
            notes: "Some notes"
          }
        }
      end

      it "permits verified, name, phone, website, notes" do
        expect(assigns(:facility).verified).to be true
        expect(assigns(:facility).name).to eq("Test")
        expect(assigns(:facility).phone).to eq("123")
        expect(assigns(:facility).website).to eq("https://test.com")
        expect(assigns(:facility).notes).to eq("Some notes")
      end
    end

    describe "strong parameters for discard" do
      let(:facility) { create(:facility) }

      before do
        delete :destroy, params: {
          id: facility.id,
          facility: {
            discard_reason: "closed",
            name: "Should not be updated"
          }
        }
      end

      it "permits discard_reason" do
        expect(assigns(:facility).discard_reason).to eq("closed")
      end
    end
  end
end
