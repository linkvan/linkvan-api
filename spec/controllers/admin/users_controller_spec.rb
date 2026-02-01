# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UsersController do
  let(:super_admin) { create(:user, :admin, :verified) }
  let(:zone_admin) { create(:user, :admin, :verified) }
  let(:regular_admin) { create(:user, :admin, :verified) }
  let(:regular_user) { create(:user, :verified) }
  let(:non_admin_user) { create(:user, :verified) }

  # Stub Devise authentication methods (common pattern from facilities_controller_spec)
  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:user_signed_in?).and_return(true)
  end

  describe "GET #index" do
    subject(:get_index) { get :index, params: params }

    let(:params) { {} }

    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
    end

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before do
        create(:user)
        get_index
      end

      it { expect(assigns(:users)).to be_present }
      it { expect(assigns(:pagy)).to be_a(Pagy) }
    end

    describe "pagination" do
      context "with many users" do
        let(:params) { { page: 1 } }
        let(:users) { create_list(:user, 25) }

        before { users && get_index }

        it "paginates users" do
          # Pagy default items is 20
          expect(assigns(:users).count).to be <= 20
        end
      end

      context "with page parameter" do
        let(:params) { { page: 2 } }

        before { create_list(:user, 30) && get_index }

        it { expect(assigns(:pagy).page).to eq(2) }
      end
    end

    context "when current_user is super_admin" do
      before { allow(controller).to receive(:current_user).and_return(super_admin) }

      it { is_expected.to have_http_status(:success) }
    end

    context "when current_user is zone_admin" do
      let(:zone) { create(:zone) }
      let(:zone_admin) { create(:user, :admin, :verified, zones: [zone]) }

      before { allow(controller).to receive(:current_user).and_return(zone_admin) }

      it { is_expected.to have_http_status(:success) }
    end
  end

  describe "GET #show" do
    subject(:get_show) { get :show, params: { id: user.id } }

    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
    end

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before { get_show }

      it { expect(assigns(:user)).to eq(user) }
    end

    context "with super_admin" do
      it "allows access" do
        get_show
        expect(response).to have_http_status(:success)
      end
    end

    context "with zone_admin managing the user" do
      let(:zone) { create(:zone) }
      let(:zone_admin) { create(:user, :admin, :verified, zones: [zone]) }
      let(:target_user) { create(:user, zones: [zone]) }

      before { allow(controller).to receive(:current_user).and_return(zone_admin) }

      it "allows access" do
        get :show, params: { id: target_user.id }
        expect(response).to have_http_status(:success)
      end
    end

    context "with zone_admin not managing the user" do
      let(:zone) { create(:zone) }
      let(:other_zone) { create(:zone) }
      let(:zone_admin) { create(:user, :admin, :verified, zones: [zone]) }
      let(:target_user) { create(:user, zones: [other_zone]) }

      before do
        allow(controller).to receive(:current_user).and_return(zone_admin)
        get :show, params: { id: target_user.id }
      end

      it { is_expected.to have_http_status(:success) }
    end
  end

  describe "GET #new" do
    subject(:get_new) { get :new }

    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
    end

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before { get_new }

      it { expect(assigns(:user)).to be_a_new(User) }
      it { expect(assigns(:user).admin).to be false }
      it { expect(assigns(:user).verified).to be false }
    end
  end

  describe "GET #edit" do
    subject(:get_edit) { get :edit, params: { id: user.id } }

    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
    end

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before { get_edit }

      it { expect(assigns(:user)).to eq(user) }
    end
  end

  describe "POST #create" do
    subject(:post_create) { post :create, params: params }

    let(:params) { { user: user_attributes } }
    let(:user_attributes) do
      {
        name: "New User",
        email: "newuser@example.com",
        phone_number: "555-1234",
        organization: "Test Organization",
        verified: true,
        password: "password123",
        password_confirmation: "password123"
      }
    end

    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
    end

    it { is_expected.to have_http_status(:redirect) }

    describe "creates a new user" do
      it { expect { post_create }.to change(User, :count).by(1) }

      context "with valid attributes" do
        it "redirects to show" do
          post_create
          expect(response).to redirect_to(admin_user_path(assigns(:user)))
        end

        it "sets flash notice" do
          post_create
          expect(flash[:notice]).to match(/Successfully created user/)
          expect(flash[:notice]).to include("id: #{assigns(:user).id}")
          expect(flash[:notice]).to include("email: newuser@example.com")
        end
      end
    end

    describe "admin attribute" do
      # The controller's current_user_admin? checks current_user.admin (boolean field)
      # So any admin user (admin=true) can set the admin attribute on other users
      context "when admin user sets admin: true" do
        let(:user_attributes) do
          {
            name: "Admin User",
            email: "admin@example.com",
            admin: true,
            verified: true,
            password: "password123",
            password_confirmation: "password123"
          }
        end

        before { post_create }

        it "creates admin user" do
          expect(assigns(:user).admin).to be true
        end
      end

      context "when non-admin tries to set admin: true" do
        let(:non_admin) { create(:user, :verified) }
        let(:user_attributes) do
          {
            name: "Admin User",
            email: "admin@example.com",
            admin: true,
            verified: true,
            password: "password123",
            password_confirmation: "password123"
          }
        end

        before do
          allow(controller).to receive(:current_user).and_return(non_admin)
          post_create
        end

        it "does not set admin attribute" do
          expect(assigns(:user).admin).to be false
        end
      end
    end

    context "with invalid attributes" do
      let(:user_attributes) { { name: nil, email: nil } }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not create a user" do
        expect { post_create }.not_to change(User, :count)
      end

      it "sets flash.now alert" do
        post_create
        expect(flash.now[:alert]).to match(/Failed to create user/)
        expect(flash.now[:alert]).to include("Errors:")
      end

      it "renders new template" do
        post_create
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PATCH #update" do
    subject(:patch_update) { patch :update, params: params }

    let(:user) { create(:user, name: "Original Name", email: "original@example.com") }
    let(:params) { { id: user.id, user: { name: "Updated Name" } } }

    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
    end

    it { is_expected.to have_http_status(:redirect) }

    context "with valid attributes" do
      it "updates the user" do
        patch_update
        expect(user.reload.name).to eq("Updated Name")
      end

      it "redirects to show" do
        patch_update
        expect(response).to redirect_to(admin_user_path(user))
      end

      it "sets flash notice" do
        patch_update
        expect(flash[:notice]).to match(/Successfully updated user/)
        expect(flash[:notice]).to include("id: #{user.id}")
      end
    end

    context "with invalid attributes" do
      let(:params) { { id: user.id, user: { name: nil } } }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not update the user" do
        patch_update
        expect(user.reload.name).to eq("Original Name")
      end

      it "sets flash.now alert" do
        patch_update
        expect(flash.now[:alert]).to match(/Failed to update user/)
        expect(flash.now[:alert]).to include("id: #{user.id}")
        expect(flash.now[:alert]).to include("Errors:")
      end

      it "renders edit template" do
        patch_update
        expect(response).to render_template(:edit)
      end
    end

    describe "admin attribute protection" do
      # The controller's current_user_admin? checks current_user.admin (boolean field)
      # So any admin user can set the admin attribute on other users
      context "when current_user is admin and updates admin attribute" do
        let(:params) { { id: user.id, user: { admin: true } } }

        before { patch_update }

        it "allows setting admin attribute" do
          expect(user.reload.admin).to be true
        end
      end

      context "when current_user is not admin tries to update admin attribute" do
        let(:non_admin) { create(:user, :verified) }
        let(:target_user) { create(:user, admin: false) }

        before do
          allow(controller).to receive(:current_user).and_return(non_admin)
          patch :update, params: { id: target_user.id, user: { admin: true } }
        end

        it "does not change admin attribute" do
          expect(target_user.reload.admin).to be false
        end
      end
    end

    describe "verified attribute" do
      context "when super_admin updates verified attribute" do
        let(:user) { create(:user, verified: false) }
        let(:params) { { id: user.id, user: { verified: true } } }

        before { patch_update }

        it "allows setting verified attribute" do
          expect(user.reload).to be_verified
        end
      end
    end
  end

  describe "DELETE #destroy" do
    subject(:delete_destroy) { delete :destroy, params: { id: user.id } }

    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
    end

    it { is_expected.to have_http_status(:redirect) }

    context "when user can be destroyed" do
      it "destroys the user" do
        user # ensure user is created
        expect { delete_destroy }.to change(User, :count).by(-1)
      end

      it "sets flash notice" do
        delete_destroy
        expect(flash[:notice]).to match(/Successfully deleted User/)
        expect(flash[:notice]).to include("id: #{user.id}")
        expect(flash[:notice]).to include("email: #{user.email}")
      end

      it "redirects to index" do
        delete_destroy
        expect(response).to redirect_to(action: :index)
      end
    end
  end

  describe "before_action callbacks" do
    describe "#load_users" do
      before do
        allow(controller).to receive(:current_user).and_return(super_admin)
        create(:user)
        get :index
      end

      it "sets @users" do
        expect(assigns(:users)).to be_present
      end

      it "sets @pagy" do
        expect(assigns(:pagy)).to be_a(Pagy)
      end
    end

    describe "#load_user" do
      before do
        allow(controller).to receive(:current_user).and_return(super_admin)
      end

      context "for show action" do
        let(:user) { create(:user) }

        before { get :show, params: { id: user.id } }

        it { expect(assigns(:user)).to eq(user) }
      end

      context "for edit action" do
        let(:user) { create(:user) }

        before { get :edit, params: { id: user.id } }

        it { expect(assigns(:user)).to eq(user) }
      end

      context "for update action" do
        let(:user) { create(:user) }

        before { patch :update, params: { id: user.id, user: { name: "New" } } }

        it { expect(assigns(:user)).to eq(user) }
      end

      context "for destroy action" do
        let(:user) { create(:user) }

        before { delete :destroy, params: { id: user.id } }

        it { expect(assigns(:user)).to eq(user) }
      end
    end
  end

  describe "flash messages" do
    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
    end

    describe "create failure" do
      before do
        post :create, params: { user: { name: nil } }
      end

      it { expect(flash.now[:alert]).to match(/Failed to create user/) }
      it { expect(flash.now[:alert]).to include("Errors:") }
    end

    describe "update success" do
      let(:user) { create(:user) }

      before do
        patch :update, params: { id: user.id, user: { name: "Updated" } }
      end

      it { expect(flash[:notice]).to match(/Successfully updated user/) }
      it { expect(flash[:notice]).to include("id: #{user.id}") }
    end

    describe "update failure" do
      let(:user) { create(:user) }

      before do
        patch :update, params: { id: user.id, user: { name: nil } }
      end

      it { expect(flash.now[:alert]).to match(/Failed to update user/) }
      it { expect(flash.now[:alert]).to include("id: #{user.id}") }
    end

    describe "destroy success" do
      let(:user) { create(:user) }

      before do
        delete :destroy, params: { id: user.id }
      end

      it { expect(flash[:notice]).to match(/Successfully deleted User/) }
      it { expect(flash[:notice]).to include(user.name) }
      it { expect(flash[:notice]).to include("id: #{user.id}") }
    end
  end

  describe "parameter filtering" do
    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
    end

    describe "strong parameters" do
      let(:user) { create(:user) }

      before do
        patch :update, params: {
          id: user.id,
          user: {
            name: "Test",
            email: "test@example.com",
            phone_number: "555-1234",
            organization: "Test Org",
            verified: true,
            admin: true,
            password: "newpassword",
            password_confirmation: "newpassword"
          }
        }
      end

      it "permits name, email, phone_number, organization, verified, password attributes" do
        expect(assigns(:user).name).to eq("Test")
        expect(assigns(:user).email).to eq("test@example.com")
        expect(assigns(:user).phone_number).to eq("555-1234")
        expect(assigns(:user).organization).to eq("Test Org")
        expect(assigns(:user).verified).to be true
        expect(assigns(:user).admin).to be true
      end

      it "permits password and password_confirmation" do
        expect(assigns(:user).password).to be_present
        expect(assigns(:user).password_confirmation).to be_present
      end
    end

    describe "admin parameter protection" do
      context "when current_user is admin" do
        let(:user) { create(:user) }

        before do
          allow(controller).to receive(:current_user).and_return(regular_admin)
          patch :update, params: { id: user.id, user: { admin: true } }
        end

        it "permits admin attribute when current_user is admin" do
          expect(user.reload.admin).to be true
        end
      end

      context "when current_user is not admin" do
        let(:user) { create(:user) }
        let(:non_admin) { create(:user, :verified) }

        before do
          allow(controller).to receive(:current_user).and_return(non_admin)
          patch :update, params: { id: user.id, user: { admin: true } }
        end

        it "does not permit admin attribute when current_user is not admin" do
          expect(user.reload.admin).to be false
        end
      end
    end
  end

  describe "permission matrix" do
    let(:zone_a) { create(:zone, name: "Zone A") }
    let(:zone_b) { create(:zone, name: "Zone B") }

    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:authenticate_user!).and_return(true)
    end

    describe "super_admin permissions" do
      let(:super_admin) { create(:user, :admin, :verified) }
      let(:user_in_zone_a) { create(:user, zones: [zone_a]) }
      let(:user_in_zone_b) { create(:user, zones: [zone_b]) }

      before do
        allow(controller).to receive(:current_user).and_return(super_admin)
      end

      it "can view any user" do
        get :show, params: { id: user_in_zone_a.id }
        expect(response).to have_http_status(:success)

        get :show, params: { id: user_in_zone_b.id }
        expect(response).to have_http_status(:success)
      end

      it "can edit any user" do
        get :edit, params: { id: user_in_zone_a.id }
        expect(response).to have_http_status(:success)

        get :edit, params: { id: user_in_zone_b.id }
        expect(response).to have_http_status(:success)
      end

      it "can update any user" do
        patch :update, params: { id: user_in_zone_a.id, user: { name: "Updated" } }
        expect(response).to have_http_status(:redirect)

        patch :update, params: { id: user_in_zone_b.id, user: { name: "Updated" } }
        expect(response).to have_http_status(:redirect)
      end

      it "can delete any user" do
        user_to_delete = create(:user)
        delete :destroy, params: { id: user_to_delete.id }
        expect(response).to have_http_status(:redirect)
      end

      it "can set admin attribute on any user" do
        user = create(:user, admin: false)
        patch :update, params: { id: user.id, user: { admin: true } }
        expect(user.reload.admin).to be true
      end
    end

    describe "zone_admin permissions" do
      let(:zone_a_admin) { create(:user, :admin, :verified, zones: [zone_a]) }
      let(:user_in_zone_a) { create(:user, zones: [zone_a]) }
      let(:user_in_zone_b) { create(:user, zones: [zone_b]) }

      before do
        allow(controller).to receive(:current_user).and_return(zone_a_admin)
      end

      it "can view users in their zone" do
        get :show, params: { id: user_in_zone_a.id }
        expect(response).to have_http_status(:success)
      end

      it "can edit users in their zone" do
        get :edit, params: { id: user_in_zone_a.id }
        expect(response).to have_http_status(:success)
      end

      it "can update users in their zone" do
        patch :update, params: { id: user_in_zone_a.id, user: { name: "Updated" } }
        expect(response).to have_http_status(:redirect)
      end

      it "can delete users in their zone" do
        user_to_delete = create(:user, zones: [zone_a])
        delete :destroy, params: { id: user_to_delete.id }
        expect(response).to have_http_status(:redirect)
      end

      it "can set admin attribute on any user" do
        # The controller's current_user_admin? checks current_user.admin (boolean field)
        # So zone admins (admin=true) can set the admin attribute on users
        user = create(:user, zones: [zone_a], admin: false)
        patch :update, params: { id: user.id, user: { admin: true } }
        expect(user.reload.admin).to be true
      end

      context "with user not in their zone" do
        it "can view users outside their zone" do
          get :show, params: { id: user_in_zone_b.id }
          expect(response).to have_http_status(:success)
        end

        it "can edit users outside their zone" do
          get :edit, params: { id: user_in_zone_b.id }
          expect(response).to have_http_status(:success)
        end

        it "can update users outside their zone" do
          user_in_zone_b.name
          patch :update, params: { id: user_in_zone_b.id, user: { name: "Updated" } }
          expect(response).to have_http_status(:redirect)
          expect(user_in_zone_b.reload.name).to eq("Updated")
        end
      end
    end
  end
end

RSpec.describe Admin::PasswordsController do
  let(:super_admin) { create(:user, :admin, :verified) }
  let(:user) { create(:user) }
  let(:non_admin_user) { create(:user, :verified) }

  # Stub Devise authentication methods
  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:user_signed_in?).and_return(true)
  end

  describe "GET #new" do
    subject(:get_new) { get :new, params: { user_id: user.id } }

    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
    end

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before { get_new }

      it { expect(assigns(:user)).to eq(user) }
    end
  end

  describe "POST #create" do
    subject(:post_create) { post :create, params: params }

    let(:params) do
      {
        user_id: user.id,
        user: {
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }
    end

    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
    end

    it { is_expected.to have_http_status(:redirect) }

    context "with valid password" do
      it "updates the user" do
        # Just verify the action completes successfully
        post_create
        expect(response).to have_http_status(:redirect)
      end

      it "redirects to user show" do
        post_create
        expect(response).to redirect_to(admin_user_path(user))
      end

      it "sets flash notice" do
        post_create
        expect(flash[:notice]).to match(/Password for user.*succesfully reset/)
        expect(flash[:notice]).to include("id: #{user.id}")
        expect(flash[:notice]).to include("email: #{user.email}")
      end
    end

    context "with invalid password" do
      let(:params) do
        {
          user_id: user.id,
          user: {
            password: "short",
            password_confirmation: "short"
          }
        }
      end

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not update successfully" do
        post_create
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "sets flash.now alert" do
        post_create
        expect(flash.now[:alert]).to match(/Failed to reset password/)
        expect(flash.now[:alert]).to include("id: #{user.id}")
        expect(flash.now[:alert]).to include("Errors:")
      end

      it "renders new template" do
        post_create
        expect(response).to render_template(:new)
      end
    end

    context "when password confirmation does not match" do
      let(:params) do
        {
          user_id: user.id,
          user: {
            password: "newpassword123",
            password_confirmation: "differentpassword"
          }
        }
      end

      before { post_create }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not update successfully" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when user does not exist" do
      let(:params) { { user_id: -1, user: { password: "password123", password_confirmation: "password123" } } }

      it { expect { post_create }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end

  describe "before_action callbacks" do
    describe "#load_user" do
      before do
        allow(controller).to receive(:current_user).and_return(super_admin)
      end

      context "for new action" do
        before { get :new, params: { user_id: user.id } }

        it { expect(assigns(:user)).to eq(user) }
      end

      context "for create action" do
        before { post :create, params: { user_id: user.id, user: { password: "password123", password_confirmation: "password123" } } }

        it { expect(assigns(:user)).to eq(user) }
      end

      context "when user not found" do
        it { expect { get :new, params: { user_id: -1 } }.to raise_error(ActiveRecord::RecordNotFound) }
      end
    end
  end

  describe "parameter filtering" do
    before do
      allow(controller).to receive(:current_user).and_return(super_admin)
      post :create, params: {
        user_id: user.id,
        user: {
          password: "newpassword123",
          password_confirmation: "newpassword123",
          name: "Should Not Be Updated",
          email: "shouldnotchange@example.com"
        }
      }
    end

    it "permits password and password_confirmation" do
      expect(assigns(:user).password).to be_present
      expect(assigns(:user).password_confirmation).to be_present
    end
  end
end
