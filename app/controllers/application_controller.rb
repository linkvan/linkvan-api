# frozen_string_literal: true

# ActionController::API
class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Prevent CSRF attacks by raising an exception.
  #   protect_from_forgery with: :null_session
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  #   respond_to :json
  # before_action :require_signin

  #   add_breadcrumb "Facilities", :root_path

  private

  # Devise hook, expects a path to redirect to
  def after_sign_in_path_for(_resource)
    admin_dashboard_index_path
  end

  # Devise hook, expects a path to redirect to
  def after_sign_out_path_for(_resource)
    new_user_session_path
  end

  def require_admin
    return if current_user_admin?

    head :unauthorized
  end

  def current_user_admin?
    user_signed_in? && current_user&.admin?
  end
end
