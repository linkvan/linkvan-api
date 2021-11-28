# frozen_string_literal: true

class Admin::PasswordsController < Admin::BaseController
  before_action :load_user

  def new; end

  def create
    user_description = "(id: #{@user.id}, email: #{@user.email})"

    if @user.update(user_params)
      redirect_to [:admin, @user], notice: "Password for user #{user_description} succesfully reset"
    else
      flash.now[:alert] = "Failed to reset password for user #{user_description}. Errors: #{@user.errors.full_messages.join('; ')}"

      render action: :new, status: :unprocessable_entity
    end
  end

  private

  def load_user
    @user = User.find(params[:user_id])
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
