# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  layout "application"
  # skip_before_action :authenticate_user!

  # helpers from devise. Example:
  #   user_signed_in?, current_user, user_session
  before_action :authenticate_user!
end
