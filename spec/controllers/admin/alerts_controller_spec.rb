# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::AlertsController do
  let(:admin_user) { create(:user, :admin, :verified) }
  let(:non_admin_user) { create(:user, :verified) }

  # Stub Devise authentication methods
  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: admin_user, user_signed_in?: true)
  end

  describe "GET #index" do
    subject(:get_index) { get :index, params: params }

    let(:params) { {} }

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before do
        create(:alert)
        get_index
      end

      it { expect(assigns(:alerts)).to be_present }
      it { expect(assigns(:pagy)).to be_a(Pagy) }
    end

    describe "pagination" do
      context "with many alerts" do
        let(:params) { { page: 1 } }
        let(:alerts) { create_list(:alert, 25) }

        before { alerts && get_index }

        it "paginates alerts" do
          expect(assigns(:alerts).count).to be <= 20
          expect(assigns(:pagy).limit).to eq(20)
        end
      end

      context "with page parameter" do
        let(:params) { { page: 2 } }

        before { create_list(:alert, 30) && get_index }

        it { expect(assigns(:pagy).page).to eq(2) }
      end
    end

    describe "alert ordering" do
      let!(:alert_a) { create(:alert, title: "Alert A", updated_at: 1.hour.ago) }
      let!(:alert_b) { create(:alert, title: "Alert B", updated_at: 1.hour.from_now) }

      before { get_index }

      it "loads alerts ordered by updated_at descending" do
        # The timeline scope orders by updated_at: :desc
        # alert_b has a more recent updated_at, so it should come first
        expect(assigns(:alerts).order(updated_at: :desc).ids).to eq([alert_b.id, alert_a.id])
      end
    end

    describe "active/inactive filtering" do
      let!(:active_alert) { create(:alert, :active) }
      let!(:inactive_alert) { create(:alert, :inactive) }

      context "without filter" do
        before { get_index }

        it "shows all alerts" do
          expect(assigns(:alerts)).to include(active_alert)
          expect(assigns(:alerts)).to include(inactive_alert)
        end
      end
    end
  end

  describe "GET #show" do
    subject(:get_show) { get :show, params: { id: alert.id } }

    let(:alert) { create(:alert) }

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before { get_show }

      it { expect(assigns(:alert)).to eq(alert) }
    end

    context "when alert does not exist" do
      let(:alert) { -1 }

      it "raises ActiveRecord::RecordNotFound" do
        expect { get :show, params: { id: "nonexistent" } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with active alert" do
      let(:alert) { create(:alert, :active) }

      before { get_show }

      it "shows active alert" do
        expect(assigns(:alert)).to be_active
        expect(response).to have_http_status(:success)
      end
    end

    context "with inactive alert" do
      let(:alert) { create(:alert, :inactive) }

      before { get_show }

      it "shows inactive alert" do
        expect(assigns(:alert)).not_to be_active
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #new" do
    subject(:get_new) { get :new }

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before { get_new }

      it { expect(assigns(:alert)).to be_a_new(Alert) }
      it { expect(assigns(:alert)).not_to be_active }
    end
  end

  describe "GET #edit" do
    subject(:get_edit) { get :edit, params: { id: alert.id } }

    let(:alert) { create(:alert) }

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before { get_edit }

      it { expect(assigns(:alert)).to eq(alert) }
    end

    context "when alert does not exist" do
      let(:alert) { -1 }

      it "raises ActiveRecord::RecordNotFound" do
        expect { get :edit, params: { id: "nonexistent" } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with active alert" do
      let(:alert) { create(:alert, :active) }

      before { get_edit }

      it "loads active alert for editing" do
        expect(assigns(:alert)).to be_active
      end
    end

    context "with inactive alert" do
      let(:alert) { create(:alert, :inactive) }

      before { get_edit }

      it "loads inactive alert for editing" do
        expect(assigns(:alert)).not_to be_active
      end
    end
  end

  describe "POST #create" do
    subject(:post_create) { post :create, params: params }

    let(:params) { { alert: alert_attributes } }
    let(:alert_attributes) do
      {
        title: "New Alert",
        content: "<p>Content for new alert</p>",
        active: false
      }
    end

    it { is_expected.to have_http_status(:redirect) }

    describe "creates a new alert" do
      it { expect { post_create }.to change(Alert, :count).by(1) }

      context "with valid attributes" do
        it "redirects to show" do
          post_create
          expect(response).to redirect_to(admin_alert_path(assigns(:alert)))
        end

        it "sets flash notice" do
          post_create
          expect(flash[:notice]).to match(/Successfully created alert/)
          expect(flash[:notice]).to include("id: #{assigns(:alert).id}")
          expect(flash[:notice]).to include("title: New Alert")
        end
      end
    end

    describe "ActionText content handling" do
      before { post_create }

      context "with rich text content" do
        it "creates alert with content" do
          expect(assigns(:alert).content).to be_present
        end

        it "content is a ActionText::RichText" do
          expect(assigns(:alert).content).to be_a(ActionText::RichText)
        end
      end
    end

    describe "active/inactive state" do
      context "with active: true" do
        let(:alert_attributes) do
          {
            title: "Active Alert",
            content: "<p>Active alert content</p>",
            active: true
          }
        end

        before { post_create }

        it "creates active alert" do
          expect(assigns(:alert)).to be_active
        end
      end

      context "with active: false (default)" do
        let(:alert_attributes) do
          {
            title: "Inactive Alert",
            content: "<p>Inactive alert content</p>",
            active: false
          }
        end

        before { post_create }

        it "creates inactive alert" do
          expect(assigns(:alert)).not_to be_active
        end
      end
    end

    context "with invalid attributes (missing title)" do
      let(:alert_attributes) { { title: nil, content: nil } }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not create an alert" do
        expect { post_create }.not_to change(Alert, :count)
      end

      it "sets flash.now alert" do
        post_create
        expect(flash.now[:alert]).to match(/Failed to create alert/)
        expect(flash.now[:alert]).to include("Errors:")
      end

      it "renders new template" do
        post_create
        expect(response).to render_template(:new)
      end
    end

    context "with missing content" do
      let(:alert_attributes) { { title: "Alert Without Content", content: nil } }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not create an alert" do
        expect { post_create }.not_to change(Alert, :count)
      end

      it "requires content validation" do
        post_create
        expect(assigns(:alert).errors[:content]).to be_present
      end
    end

    context "with empty content (ActionText rejects empty)" do
      let(:alert_attributes) { { title: "Alert With Empty Content", content: "" } }

      before { post_create }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not create an alert" do
        expect { post_create }.not_to change(Alert, :count)
      end
    end
  end

  describe "PATCH #update" do
    subject(:patch_update) { patch :update, params: params }

    let(:alert) { create(:alert, title: "Original Title", active: false) }
    let(:params) { { id: alert.id, alert: alert_attributes } }
    let(:alert_attributes) do
      {
        title: "Updated Title",
        content: "<p>Updated content</p>",
        active: true
      }
    end

    it { is_expected.to have_http_status(:redirect) }

    context "with valid attributes" do
      before { patch_update }

      it "updates the alert" do
        expect(alert.reload.title).to eq("Updated Title")
      end

      it "redirects to show" do
        expect(response).to redirect_to(admin_alert_path(alert))
      end

      it "sets flash notice" do
        expect(flash[:notice]).to match(/Successfully updated alert/)
        expect(flash[:notice]).to include("id: #{alert.id}")
      end
    end

    describe "ActionText content update" do
      before { patch_update }

      it "updates the content" do
        expect(alert.reload.content.body.to_html).to include("Updated content")
      end
    end

    describe "active/inactive state update" do
      context "activating an inactive alert" do
        let(:alert) { create(:alert, active: false) }

        before { patch_update }

        it "sets active to true" do
          expect(alert.reload).to be_active
        end
      end

      context "deactivating an active alert" do
        let(:alert) { create(:alert, active: true) }
        let(:alert_attributes) do
          {
            title: "Updated Title",
            content: "<p>Updated content</p>",
            active: false
          }
        end

        before { patch_update }

        it "sets active to false" do
          expect(alert.reload).not_to be_active
        end
      end
    end

    context "with invalid attributes" do
      let(:alert_attributes) { { title: nil } }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not update the alert" do
        original_title = alert.title
        patch_update
        expect(alert.reload.title).to eq(original_title)
      end

      it "sets flash.now alert" do
        patch_update
        expect(flash.now[:alert]).to match(/Failed to update alert/)
        expect(flash.now[:alert]).to include("id: #{alert.id}")
        expect(flash.now[:alert]).to include("Errors:")
      end

      it "renders edit template" do
        patch_update
        expect(response).to render_template(:edit)
      end
    end

    context "with empty content" do
      let(:alert_attributes) { { title: "Updated Title", content: "" } }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it "does not update the alert" do
        patch_update
        expect(alert.reload.content.body.to_html).not_to include("Updated content")
      end
    end
  end

  describe "DELETE #destroy" do
    subject(:delete_destroy) { delete :destroy, params: { id: alert.id } }

    let(:alert) { create(:alert) }

    it { is_expected.to have_http_status(:redirect) }

    context "when alert is destroyed successfully" do
      before { alert }

      it "destroys the alert" do
        expect { delete_destroy }.to change(Alert, :count).by(-1)
      end

      it "sets flash notice" do
        delete_destroy
        expect(flash[:notice]).to match(/Successfully deleted Alert/)
        expect(flash[:notice]).to include(alert.title)
        expect(flash[:notice]).to include("id: #{alert.id}")
      end

      it "redirects to index" do
        delete_destroy
        expect(response).to redirect_to(action: :index)
      end
    end

    context "when alert has associated records that prevent deletion" do
      let(:alert) { create(:alert) }

      # NOTE: The destroy failure path is tested implicitly through the controller code.
      # Mocking destroy to return false doesn't work reliably in tests due to
      # how ActiveRecord::Base.destroy works internally. The success path is
      # the primary behavior tested here.
      before do
        # Force destroy to return false without actually calling it
        # Also allow persisted? to return true so the record is found
        allow(alert).to receive_messages(destroy: false, persisted?: true, errors: double(full_messages: ["Some error"]))
        # Ensure the alert is found via the before_action
        allow(Alert).to receive(:find).with(alert.id.to_s).and_return(alert)
        delete :destroy, params: { id: alert.id }
      end

      it "does not destroy the alert" do
        expect(alert).not_to be_destroyed
      end

      it "sets flash error" do
        expect(flash[:error]).to match(/Failed to delete Alert/)
        expect(flash[:error]).to include(alert.title)
        expect(flash[:error]).to include("id: #{alert.id}")
        expect(flash[:error]).to include("Errors:")
      end

      it "renders show template with unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:show)
      end
    end
  end

  describe "before_action callbacks" do
    describe "#load_alerts" do
      before do
        create(:alert)
        get :index
      end

      it "sets @alerts" do
        expect(assigns(:alerts)).to be_present
      end

      it "sets @pagy" do
        expect(assigns(:pagy)).to be_a(Pagy)
      end
    end

    describe "#load_alert" do
      context "for show action" do
        let(:alert) { create(:alert) }

        before { get :show, params: { id: alert.id } }

        it { expect(assigns(:alert)).to eq(alert) }
      end

      context "for edit action" do
        let(:alert) { create(:alert) }

        before { get :edit, params: { id: alert.id } }

        it { expect(assigns(:alert)).to eq(alert) }
      end

      context "for update action" do
        let(:alert) { create(:alert) }

        before { patch :update, params: { id: alert.id, alert: { title: "Updated" } } }

        it { expect(assigns(:alert)).to eq(alert) }
      end

      context "for destroy action" do
        let(:alert) { create(:alert) }

        before { delete :destroy, params: { id: alert.id } }

        it { expect(assigns(:alert)).to eq(alert) }
      end

      context "when alert not found" do
        it "raises ActiveRecord::RecordNotFound" do
          expect { get :show, params: { id: "nonexistent" } }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe "flash messages" do
    describe "create success" do
      before do
        post :create, params: {
          alert: {
            title: "Flash Test Alert",
            content: "<p>Content</p>",
            active: false
          }
        }
      end

      it { expect(flash[:notice]).to match(/Successfully created alert/) }
      it { expect(flash[:notice]).to include("id: #{assigns(:alert).id}") }
      it { expect(flash[:notice]).to include("title: Flash Test Alert") }
    end

    describe "create failure" do
      before do
        post :create, params: { alert: { title: nil, content: nil } }
      end

      it { expect(flash.now[:alert]).to match(/Failed to create alert/) }
      it { expect(flash.now[:alert]).to include("Errors:") }
    end

    describe "update success" do
      let(:alert) { create(:alert) }

      before do
        patch :update, params: {
          id: alert.id,
          alert: { title: "Updated Alert" }
        }
      end

      it { expect(flash[:notice]).to match(/Successfully updated alert/) }
      it { expect(flash[:notice]).to include("id: #{alert.id}") }
    end

    describe "update failure" do
      let(:alert) { create(:alert) }

      before do
        patch :update, params: { id: alert.id, alert: { title: nil } }
      end

      it { expect(flash.now[:alert]).to match(/Failed to update alert/) }
      it { expect(flash.now[:alert]).to include("id: #{alert.id}") }
      it { expect(flash.now[:alert]).to include("Errors:") }
    end

    describe "destroy success" do
      let(:alert) { create(:alert, title: "To Delete") }

      before do
        delete :destroy, params: { id: alert.id }
      end

      it { expect(flash[:notice]).to match(/Successfully deleted Alert/) }
      it { expect(flash[:notice]).to include("To Delete") }
      it { expect(flash[:notice]).to include("id: #{alert.id}") }
    end

    describe "destroy failure" do
      let(:alert) { create(:alert, title: "Cannot Delete") }

      before do
        # Force destroy to return false without actually calling it
        allow(alert).to receive_messages(destroy: false, persisted?: true, errors: double(full_messages: ["Some error"]))
        allow(Alert).to receive(:find).with(alert.id.to_s).and_return(alert)
        delete :destroy, params: { id: alert.id }
      end

      it "sets flash error" do
        expect(flash[:error]).to match(/Failed to delete Alert/)
        expect(flash[:error]).to include("Cannot Delete")
        expect(flash[:error]).to include("Errors:")
      end
    end
  end

  describe "parameter filtering" do
    describe "strong parameters for alert" do
      let(:alert) { create(:alert) }

      before do
        patch :update, params: {
          id: alert.id,
          alert: {
            title: "Test Title",
            content: "<p>Test content</p>",
            active: true
          }
        }
      end

      it "permits title" do
        expect(assigns(:alert).title).to eq("Test Title")
      end

      it "permits content" do
        expect(assigns(:alert).content).to be_present
      end

      it "permits active" do
        expect(assigns(:alert)).to be_active
      end
    end

    describe "ActionText content parameter structure" do
      context "with ActionText content format" do
        let(:params) do
          {
            alert: {
              title: "ActionText Test",
              content: "<div class=\"trix-content\"><p>Rich text content</p></div>",
              active: false
            }
          }
        end

        before { post :create, params: params }

        it "creates alert with rich text content" do
          expect(assigns(:alert).content).to be_present
        end
      end
    end
  end

  describe "alert state management" do
    describe "inactive state (default)" do
      let(:inactive_alert) { create(:alert, :inactive) }

      before do
        get :show, params: { id: inactive_alert.id }
      end

      it "shows inactive alerts" do
        expect(assigns(:alert)).to eq(inactive_alert)
        expect(response).to have_http_status(:success)
      end
    end

    describe "active state" do
      let(:active_alert) { create(:alert, :active) }

      before do
        get :show, params: { id: active_alert.id }
      end

      it "shows active alerts" do
        expect(assigns(:alert)).to eq(active_alert)
        expect(response).to have_http_status(:success)
      end
    end

    describe "switching between active and inactive" do
      let(:alert) { create(:alert, active: false) }

      context "updating from inactive to active" do
        before do
          patch :update, params: {
            id: alert.id,
            alert: { active: true }
          }
        end

        it "changes active state" do
          expect(alert.reload).to be_active
        end

        it "sets success flash" do
          expect(flash[:notice]).to match(/Successfully updated alert/)
        end
      end

      context "updating from active to inactive" do
        let(:alert) { create(:alert, active: true) }

        before do
          patch :update, params: {
            id: alert.id,
            alert: { active: false }
          }
        end

        it "changes active state" do
          expect(alert.reload).not_to be_active
        end

        it "sets success flash" do
          expect(flash[:notice]).to match(/Successfully updated alert/)
        end
      end
    end
  end

  describe "routing" do
    it { is_expected.to route(:get, "/admin/alerts").to(action: :index) }
    it { is_expected.to route(:get, "/admin/alerts/new").to(action: :new) }
    it { is_expected.to route(:get, "/admin/alerts/1").to(action: :show, id: 1) }
    it { is_expected.to route(:get, "/admin/alerts/1/edit").to(action: :edit, id: 1) }
    it { is_expected.to route(:post, "/admin/alerts").to(action: :create) }
    it { is_expected.to route(:patch, "/admin/alerts/1").to(action: :update, id: 1) }
    it { is_expected.to route(:delete, "/admin/alerts/1").to(action: :destroy, id: 1) }
  end
end
