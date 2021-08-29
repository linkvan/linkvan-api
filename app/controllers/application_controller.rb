# frozen_string_literal: true

# ActionController::API
class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Prevent CSRF attacks by raising an exception.
  #   protect_from_forgery with: :null_session
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  #   respond_to :json
  before_action :require_signin

  #   add_breadcrumb "Facilities", :root_path

  private

  # def allow_iframe_requests
  #   response.headers.delete('X-Frame-Options')
  # end

  def require_signin
    retun if current_user

    # session[:intended_url] = request.url
    # redirect_to new_session_url, alert: "Please sign in first"
    head :unauthorized
  end

  def current_user
    # if !session[:user_id].blank?
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    # end
  end

  def require_admin
    return if current_user_admin?

    head :unauthorized
    # redirect_to root_url, alert: "Unauthorized access!"
  end

  def current_user_admin?
    current_user&.admin?
  end

  def require_correct_user_or_admin
    redirect_to root_url unless current_user == User.find(params[:id]) || current_user_admin?
  end

  def correct_user_or_admin?
    if current_user_admin?
      true
    elsif current_user
      current_user.facilities.each do |f|
        return true if f.id == Facility.find(params[:id]).id
      end
      false
    end
  end

  # helper_method :current_user, :current_user_admin?, :require_correct_user_or_admin, :correct_user_or_admin?
end
