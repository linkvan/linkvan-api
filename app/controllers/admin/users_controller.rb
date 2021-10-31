# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
  before_action :load_users, only: %i[index]
  before_action :load_user, only: %i[show edit update destroy]

  def index; end

  def show; end

  def edit; end

  def update; end

  def destroy; end

  private

  def load_users
    users = User.all

    @pagy, @users = pagy(users)
  end

  def load_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit()
  end
end
