class Admin::BaseController < ApplicationController
  skip_before_action :require_signin
  # before_action :set_default_request_format

  private
  # def set_default_request_format
  # request.format = :json unless params[:fomat]
  # end
end
