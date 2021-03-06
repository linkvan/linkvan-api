# frozen_string_literal: true

class Api::BaseController < ActionController::API # ApplicationController #ActionController::API
  before_action :require_signin

  private
    def require_signin
      head :unauthorized unless current_user
    end
end
