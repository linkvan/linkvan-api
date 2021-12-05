# frozen_string_literal: true

class Admin::NoticesController < Admin::BaseController
  before_action :load_notices, only: %i[index]
  before_action :load_notice, only: %i[show edit update destroy]

  def index; end

  def new
    @notice = Notice.new(published: false, notice_type: :general)
  end

  def show; end

  def edit; end

  def create
    @notice = Notice.new(notice_params)
    if @notice.save
      redirect_to [:admin, @notice], notice: "Successfully created notice (id: #{@notice.id}, title: #{@notice.title})"
    else
      flash.now[:notice] = "Failed to create notice. Errors: #{@notice.errors.full_messages.join('; ')}"

      render action: :new, status: :unprocessable_entity
    end
  end

  def update
    if @notice.update(notice_params)
      redirect_to [:admin, @notice], notice: "Successfully updated notice (id: #{@notice.id})"
    else
      flash.now[:notice] = "Failed to update notice (id: #{@notice.id}). Errors: #{@notice.errors.full_messages.join('; ')}"

      render action: :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @notice.destroy
      flash[:notice] = "Successfully deleted Notice #{@notice.title} (id: #{@notice.id})"

      redirect_to action: :index
    else
      # Error when turning Welcome on.
      flash[:error] = "Failed to delete Notice #{@notice.title} (id: #{@notice.id}). Errors: #{@notice.errors.full_messages.join('; ')}"

      render action: :show, status: :unprocessable_entity
    end
  end

  private

  def load_notices
    notices = Notice.all

    @pagy, @notices = pagy(notices)
  end

  def load_notice
    @notice = Notice.find(params[:id])
  end

  def notice_params
    params.require(:notice).permit(:title, :content, :published, :notice_type)
  end
end
