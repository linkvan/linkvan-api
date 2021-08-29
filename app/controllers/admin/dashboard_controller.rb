# frozen_string_literal: true

class Admin::DashboardController < Admin::BaseController
  # before_action :set_default_request_format

  def index
    flash.now[:notice] = "notice test"
    flash.now[:alert] = "error test"
  end

  # def set_default_request_format
  # request.format = :json unless params[:fomat]
  # end
end
