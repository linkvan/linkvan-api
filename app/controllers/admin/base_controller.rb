# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  layout "application_admin"
  # skip_before_action :authenticate_user!

  # helpers from devise. Example:
  #   user_signed_in?, current_user, user_session
  before_action :authenticate_user!


  # before_action :set_default_request_format

  # def set_default_request_format
  # request.format = :json unless params[:fomat]
  # end
end
