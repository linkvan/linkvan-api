# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  skip_before_action :require_signin
  # before_action :set_default_request_format

  # def set_default_request_format
  # request.format = :json unless params[:fomat]
  # end
end
