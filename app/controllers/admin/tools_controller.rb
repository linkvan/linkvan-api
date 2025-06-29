# frozen_string_literal: true

class Admin::ToolsController < Admin::BaseController
  before_action :enforce_admin_user

  def index
    
  end

  def import_facilities
    api_key = params[:api]

    # Validate that both parameters are present and supported
    unless External::SupportedApisConfig.supported_api?(api_key)
      redirect_to admin_tools_path, alert: "Invalid API selected. Please choose from the supported APIs."
      return
    end
  end

  # Helper method for the view
  helper_method :api_options_for_select

  private

  def api_options_for_select
    [['Select an API...', '']] + External::SupportedApisConfig.api_options
  end

  def enforce_admin_user
    redirect_to root_path, alert: "Access denied! You must be an admin to access tools" unless current_user&.admin?
  end
end