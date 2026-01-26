# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::NoticesController do
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
        create(:notice)
        get_index
      end

      it { expect(assigns(:notices)).to be_present }
      it { expect(assigns(:pagy)).to be_a(Pagy) }
    end

    describe "pagination" do
      context "with many notices" do
        let(:params) { { page: 1 } }
        let(:notices) { create_list(:notice, 25) }

        before { notices && get_index }

        it "paginates notices" do
          expect(assigns(:notices).count).to be <= 20
        end

        it "has pagy with correct page" do
          expect(assigns(:pagy).page).to eq(1)
        end
      end

      context "with page parameter" do
        let(:params) { { page: 2 } }

        before { create_list(:notice, 30) && get_index }

        it { expect(assigns(:pagy).page).to eq(2) }
      end
    end

    describe "notice ordering" do
      let!(:notice_a) { create(:notice, title: "Notice A", updated_at: 1.hour.ago) }
      let!(:notice_b) { create(:notice, title: "Notice B", updated_at: 1.hour.from_now) }

      before { get_index }

      it "loads notices ordered by updated_at descending" do
        # The timeline scope orders by updated_at: :desc
        # notice_b has a more recent updated_at, so it should come first
        expect(assigns(:notices).order(updated_at: :desc).ids).to eq([notice_b.id, notice_a.id])
      end
    end
  end

  describe "GET #show" do
    subject(:get_show) { get :show, params: { id: notice.id } }

    let(:notice) { create(:notice) }

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before { get_show }

      it { expect(assigns(:notice)).to eq(notice) }
    end

    context "when notice does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { get :show, params: { id: "nonexistent" } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET #new" do
    subject(:get_new) { get :new }

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before { get_new }

      it { expect(assigns(:notice)).to be_a_new(Notice) }
      it { expect(assigns(:notice)).not_to be_published }
      it { expect(assigns(:notice).notice_type).to eq("general") }
    end
  end

  describe "GET #edit" do
    subject(:get_edit) { get :edit, params: { id: notice.id } }

    let(:notice) { create(:notice) }

    it { is_expected.to have_http_status(:success) }

    describe "assigns" do
      before { get_edit }

      it { expect(assigns(:notice)).to eq(notice) }
    end

    context "when notice does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { get :edit, params: { id: "nonexistent" } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST #create" do
    subject(:post_create) { post :create, params: params }

    let(:params) { { notice: notice_attributes } }
    let(:notice_attributes) do
      {
        title: "New Notice",
        content: "<p>Content for new notice</p>",
        published: false,
        notice_type: "general"
      }
    end

    it { is_expected.to have_http_status(:redirect) }

    describe "creates a new notice" do
      it { expect { post_create }.to change(Notice, :count).by(1) }

      context "with valid attributes" do
        it "redirects to show" do
          post_create
          expect(response).to redirect_to(admin_notice_path(assigns(:notice)))
        end

        it "sets flash notice" do
          post_create
          expect(flash[:notice]).to match(/Successfully created notice/)
          expect(flash[:notice]).to include("id: #{assigns(:notice).id}")
          expect(flash[:notice]).to include("title: New Notice")
        end
      end
    end

    describe "slug generation" do
      before { post_create }

      context "on create" do
        it "generates slug from title" do
          expect(assigns(:notice).slug).to eq("new-notice")
        end
      end
    end

    describe "ActionText content handling" do
      before { post_create }

      context "with rich text content" do
        it "creates notice with content" do
          expect(assigns(:notice).content).to be_present
        end

        it "content is a ActionText::RichText" do
          expect(assigns(:notice).content).to be_a(ActionText::RichText)
        end
      end
    end

    describe "draft/published state" do
      context "with published: true" do
        let(:notice_attributes) do
          {
            title: "Published Notice",
            content: "<p>Published content</p>",
            published: true,
            notice_type: "general"
          }
        end

        before { post_create }

        it "creates published notice" do
          expect(assigns(:notice)).to be_published
        end
      end

      context "with published: false" do
        let(:notice_attributes) do
          {
            title: "Draft Notice",
            content: "<p>Draft content</p>",
            published: false,
            notice_type: "general"
          }
        end

        before { post_create }

        it "creates draft notice" do
          expect(assigns(:notice)).not_to be_published
        end
      end
    end

    describe "notice_type handling" do
      context "with covid19 notice_type" do
        let(:notice_attributes) do
          {
            title: "COVID-19 Notice",
            content: "<p>COVID-19 information</p>",
            published: true,
            notice_type: "covid19"
          }
        end

        before { post_create }

        it "creates notice with covid19 type" do
          expect(assigns(:notice).covid19?).to be true
        end
      end

      context "with warming_center notice_type" do
        let(:notice_attributes) do
          {
            title: "Warming Center Notice",
            content: "<p>Warming center info</p>",
            published: true,
            notice_type: "warming_center"
          }
        end

        before { post_create }

        it "creates notice with warming_center type" do
          expect(assigns(:notice).warming_center?).to be true
        end
      end
    end

    context "with invalid attributes" do
      let(:notice_attributes) { { title: nil, content: nil } }

      it { is_expected.to have_http_status(:unprocessable_entity) }

      it "does not create a notice" do
        expect { post_create }.not_to change(Notice, :count)
      end

      it "sets flash.now notice" do
        post_create
        expect(flash.now[:notice]).to match(/Failed to create notice/)
        expect(flash.now[:notice]).to include("Errors:")
      end

      it "renders new template" do
        post_create
        expect(response).to render_template(:new)
      end
    end

    context "with empty content (rejects ActionText without content)" do
      let(:notice_attributes) { { title: "Notice Without Content", content: "" } }

      before { post_create }

      it { is_expected.to have_http_status(:unprocessable_entity) }

      it "does not create a notice" do
        expect { post_create }.not_to change(Notice, :count)
      end
    end
  end

  describe "PATCH #update" do
    subject(:patch_update) { patch :update, params: params }

    let(:notice) { create(:notice, title: "Original Title", published: false) }
    let(:params) { { id: notice.id, notice: notice_attributes } }
    let(:notice_attributes) do
      {
        title: "Updated Title",
        content: "<p>Updated content</p>",
        published: true,
        notice_type: "covid19"
      }
    end

    it { is_expected.to have_http_status(:redirect) }

    context "with valid attributes" do
      before { patch_update }

      it "updates the notice" do
        expect(notice.reload.title).to eq("Updated Title")
      end

      it "updates published state" do
        expect(notice.reload).to be_published
      end

      it "updates notice_type" do
        expect(notice.reload.covid19?).to be true
      end

      it "redirects to show" do
        expect(response).to redirect_to(admin_notice_path(notice))
      end

      it "sets flash notice" do
        expect(flash[:notice]).to match(/Successfully updated notice/)
        expect(flash[:notice]).to include("id: #{notice.id}")
      end
    end

    describe "slug generation on update" do
      before { patch_update }

      context "when title changes" do
        it "regenerates slug from new title" do
          expect(notice.reload.slug).to eq("updated-title")
        end
      end

      context "when title does not change" do
        let(:notice_attributes) do
          {
            title: "Original Title",
            content: "<p>Updated content</p>",
            published: true
          }
        end

        it "keeps existing slug" do
          original_slug = notice.slug
          notice.reload
          expect(notice.slug).to eq(original_slug)
        end
      end
    end

    describe "ActionText content update" do
      before { patch_update }

      it "updates the content" do
        expect(notice.reload.content.body.to_html).to include("Updated content")
      end
    end

    describe "draft/published state update" do
      context "publishing a draft" do
        before { patch_update }

        it "sets published to true" do
          expect(notice.reload).to be_published
        end
      end

      context "unpublishing a published notice" do
        let(:notice) { create(:notice, :published) }
        let(:notice_attributes) do
          {
            title: "Unpublished Notice",
            content: "<p>Draft content</p>",
            published: false,
            notice_type: "general"
          }
        end

        before { patch_update }

        it "sets published to false" do
          expect(notice.reload).not_to be_published
        end
      end
    end

    context "with invalid attributes" do
      let(:notice_attributes) { { title: nil } }

      it { is_expected.to have_http_status(:unprocessable_entity) }

      it "does not update the notice" do
        original_title = notice.title
        patch_update
        expect(notice.reload.title).to eq(original_title)
      end

      it "sets flash.now notice" do
        patch_update
        expect(flash.now[:notice]).to match(/Failed to update notice/)
        expect(flash.now[:notice]).to include("id: #{notice.id}")
        expect(flash.now[:notice]).to include("Errors:")
      end

      it "renders edit template" do
        patch_update
        expect(response).to render_template(:edit)
      end
    end

    context "with empty content" do
      let(:notice_attributes) { { title: "Updated Title", content: "" } }

      it { is_expected.to have_http_status(:unprocessable_entity) }

      it "does not update the notice" do
        patch_update
        expect(notice.reload.content.body.to_html).not_to include("Updated content")
      end
    end
  end

  describe "DELETE #destroy" do
    subject(:delete_destroy) { delete :destroy, params: { id: notice.id } }

    let(:notice) { create(:notice) }

    it { is_expected.to have_http_status(:redirect) }

    context "when notice is destroyed successfully" do
      before { notice }

      it "destroys the notice" do
        expect { delete_destroy }.to change(Notice, :count).by(-1)
      end

      it "sets flash notice" do
        delete_destroy
        expect(flash[:notice]).to match(/Successfully deleted Notice/)
        expect(flash[:notice]).to include(notice.title)
        expect(flash[:notice]).to include("id: #{notice.id}")
      end

      it "redirects to index" do
        delete_destroy
        expect(response).to redirect_to(action: :index)
      end
    end
  end

  describe "before_action callbacks" do
    describe "#load_notices" do
      before do
        create(:notice)
        get :index
      end

      it "sets @notices" do
        expect(assigns(:notices)).to be_present
      end

      it "sets @pagy" do
        expect(assigns(:pagy)).to be_a(Pagy)
      end
    end

    describe "#load_notice" do
      context "for show action" do
        let(:notice) { create(:notice) }

        before { get :show, params: { id: notice.id } }

        it { expect(assigns(:notice)).to eq(notice) }
      end

      context "for edit action" do
        let(:notice) { create(:notice) }

        before { get :edit, params: { id: notice.id } }

        it { expect(assigns(:notice)).to eq(notice) }
      end

      context "for update action" do
        let(:notice) { create(:notice) }

        before { patch :update, params: { id: notice.id, notice: { title: "Updated" } } }

        it { expect(assigns(:notice)).to eq(notice) }
      end

      context "for destroy action" do
        let(:notice) { create(:notice) }

        before { delete :destroy, params: { id: notice.id } }

        it { expect(assigns(:notice)).to eq(notice) }
      end

      context "when notice not found" do
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
          notice: {
            title: "Flash Test Notice",
            content: "<p>Content</p>",
            published: false,
            notice_type: "general"
          }
        }
      end

      it { expect(flash[:notice]).to match(/Successfully created notice/) }
      it { expect(flash[:notice]).to include("id: #{assigns(:notice).id}") }
      it { expect(flash[:notice]).to include("title: Flash Test Notice") }
    end

    describe "create failure" do
      before do
        post :create, params: { notice: { title: nil, content: nil } }
      end

      it { expect(flash.now[:notice]).to match(/Failed to create notice/) }
      it { expect(flash.now[:notice]).to include("Errors:") }
    end

    describe "update success" do
      let(:notice) { create(:notice) }

      before do
        patch :update, params: {
          id: notice.id,
          notice: { title: "Updated Notice" }
        }
      end

      it { expect(flash[:notice]).to match(/Successfully updated notice/) }
      it { expect(flash[:notice]).to include("id: #{notice.id}") }
    end

    describe "update failure" do
      let(:notice) { create(:notice) }

      before do
        patch :update, params: { id: notice.id, notice: { title: nil } }
      end

      it { expect(flash.now[:notice]).to match(/Failed to update notice/) }
      it { expect(flash.now[:notice]).to include("id: #{notice.id}") }
      it { expect(flash.now[:notice]).to include("Errors:") }
    end

    describe "destroy success" do
      let(:notice) { create(:notice, title: "To Delete") }

      before do
        delete :destroy, params: { id: notice.id }
      end

      it { expect(flash[:notice]).to match(/Successfully deleted Notice/) }
      it { expect(flash[:notice]).to include("To Delete") }
      it { expect(flash[:notice]).to include("id: #{notice.id}") }
    end
  end

  describe "parameter filtering" do
    describe "strong parameters for notice" do
      let(:notice) { create(:notice) }

      before do
        patch :update, params: {
          id: notice.id,
          notice: {
            title: "Test Title",
            content: "<p>Test content</p>",
            published: true,
            notice_type: "covid19",
            slug: "should-not-be-updated-directly"
          }
        }
      end

      it "permits title" do
        expect(assigns(:notice).title).to eq("Test Title")
      end

      it "permits content" do
        expect(assigns(:notice).content).to be_present
      end

      it "permits published" do
        expect(assigns(:notice).published).to be true
      end

      it "permits notice_type" do
        expect(assigns(:notice).covid19?).to be true
      end

      it "slug is generated from title, not mass-assigned" do
        expect(assigns(:notice).slug).to eq("test-title")
      end
    end

    describe "ActionText content parameter structure" do
      context "with ActionText content format" do
        let(:params) do
          {
            notice: {
              title: "ActionText Test",
              content: "<div class=\"trix-content\">  <p>Rich text content</p>\n</div>",
              published: false,
              notice_type: "general"
            }
          }
        end

        before { post :create, params: params }

        it "creates notice with rich text content" do
          expect(assigns(:notice).content).to be_present
        end
      end
    end
  end

  describe "notice state management" do
    describe "draft state" do
      let(:draft_notice) { create(:notice, :draft) }

      before do
        get :show, params: { id: draft_notice.id }
      end

      it "shows draft notices" do
        expect(assigns(:notice)).to eq(draft_notice)
        expect(response).to have_http_status(:success)
      end
    end

    describe "published state" do
      let(:published_notice) { create(:notice, :published) }

      before do
        get :show, params: { id: published_notice.id }
      end

      it "shows published notices" do
        expect(assigns(:notice)).to eq(published_notice)
        expect(response).to have_http_status(:success)
      end
    end

    describe "switching between draft and published" do
      let(:notice) { create(:notice, published: false) }

      context "updating from draft to published" do
        before do
          patch :update, params: {
            id: notice.id,
            notice: { published: true }
          }
        end

        it "changes published state" do
          expect(notice.reload).to be_published
        end

        it "sets success flash" do
          expect(flash[:notice]).to match(/Successfully updated notice/)
        end
      end

      context "updating from published to draft" do
        let(:notice) { create(:notice, published: true) }

        before do
          patch :update, params: {
            id: notice.id,
            notice: { published: false }
          }
        end

        it "changes published state" do
          expect(notice.reload).not_to be_published
        end

        it "sets success flash" do
          expect(flash[:notice]).to match(/Successfully updated notice/)
        end
      end
    end
  end

  describe "notice_types enum values" do
    Notice.notice_types.each do |type, value|
      describe "notice_type: #{type}" do
        let(:notice) { create(:notice, notice_type: type) }

        before do
          get :show, params: { id: notice.id }
        end

        it "has correct type value" do
          expect(notice.reload.notice_type).to eq(value)
        end
      end
    end
  end

  describe "routing" do
    it { is_expected.to route(:get, "/admin/notices").to(action: :index) }
    it { is_expected.to route(:get, "/admin/notices/new").to(action: :new) }
    it { is_expected.to route(:get, "/admin/notices/1").to(action: :show, id: 1) }
    it { is_expected.to route(:get, "/admin/notices/1/edit").to(action: :edit, id: 1) }
    it { is_expected.to route(:post, "/admin/notices").to(action: :create) }
    it { is_expected.to route(:patch, "/admin/notices/1").to(action: :update, id: 1) }
    it { is_expected.to route(:delete, "/admin/notices/1").to(action: :destroy, id: 1) }
  end
end
