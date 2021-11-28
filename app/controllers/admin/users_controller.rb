# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
  before_action :load_users, only: %i[index]
  before_action :load_user, only: %i[show edit update destroy]

  def index; end

  def new
    @user = User.new(admin: false, verified: false)
  end

  def show; end

  def edit; end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to [:admin, @user], notice: "Successfully created user (id: #{@user.id}, email: #{@user.email})"
    else
      flash.now[:alert] = "Failed to create user. Errors: #{@user.errors.full_messages.join('; ')}"

      render action: :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      redirect_to [:admin, @user], notice: "Successfully updated user (id: #{@user.id})"
    else
      flash.now[:alert] = "Failed to update user (id: #{@user.id}). Errors: #{@user.errors.full_messages.join('; ')}"

      render action: :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:notice] = "Successfully deleted User #{@user.name} (id: #{@user.id}, email: #{@user.email})"

      redirect_to action: :index
    else
      # Error when turning Welcome on.
      flash[:error] = "Failed to delete User #{@user.name} (id: #{@user.id}, email: #{@user.email}). Errors: #{@user.errors.full_messages.join('; ')}"

      render action: :show, status: :unprocessable_entity
    end
  end

  private

  def load_users
    users = User.all

    @pagy, @users = pagy(users)
  end

  def load_user
    @user = User.find(params[:id])
  end

  def user_params
    parameters = params.require(:user).permit(:name, :email, :phone_number, :organization, :verified, :password, :password_confirmation)
    parameters[:admin] = params.dig(:user, :admin) if current_user_admin?

    parameters
  end
end
