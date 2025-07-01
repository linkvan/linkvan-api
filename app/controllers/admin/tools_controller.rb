# frozen_string_literal: true

class Admin::ToolsController < Admin::BaseController
  before_action :enforce_admin_user

  def index
    
  end

  def import_facilities
    api_key = params[:api]

    # Validate that both parameters are present and supported
    unless External::ApiHelper.supported_api?(api_key)
      redirect_to admin_tools_path, alert: "Invalid API selected. Please choose from the supported APIs."
      return
    end

    result = External::VancouverCity::Syncer.call(
      api_key: api_key,
      api_client: External::VancouverCity.default_client
    )

    if result.success?
      total_count = result.data[:total_count] || 0
      redirect_to admin_facilities_path(service: "water_fountain"), notice: "#{total_count} Facilities imported successfully from #{External::ApiHelper.api_name(api_key)}."
    else
      error_messages = result.errors.join(', ')
      redirect_to admin_tools_path, alert: "Failed to import facilities: #{error_messages}"
    end
  end

  # Helper method for the view
  helper_method :api_options_for_select

  private

  def api_options_for_select
    External::ApiHelper.api_options
  end

  def enforce_admin_user
    redirect_to root_path, alert: "Access denied! You must be an admin to access tools" unless current_user&.admin?
  end
end