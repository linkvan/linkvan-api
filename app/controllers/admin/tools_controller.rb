# frozen_string_literal: true

class Admin::ToolsController < Admin::BaseController
  before_action :enforce_admin_user

  def index; end

  def import_facilities
    api_key = params[:api]

    # Validate that both parameters are present and supported
    unless External::ApiHelper.supported_api?(api_key)
      redirect_to admin_tools_path, alert: "Invalid API selected. Please choose from the supported APIs."
      return
    end

    result = External::VancouverCity::Syncer.call(
      api_key: api_key,
      api_client: External::VancouverCity.default_client,
      full_sync: true
    )

    if result.success?
      created = result.data[:created_count] || 0
      updated = result.data[:updated_count] || 0
      deleted = result.data[:deleted_count] || 0
      redirect_to admin_facilities_path(service: "water_fountain"), notice: "Sync complete: #{created} created, #{updated} updated, #{deleted} removed from #{External::ApiHelper.api_name(api_key)}."
    else
      error_messages = result.errors.join(", ")
      redirect_to admin_tools_path, alert: "Failed to import facilities: #{error_messages}"
    end
  end

  def purge_facilities
    api_key = params[:api]

    unless External::ApiHelper.supported_api?(api_key)
      redirect_to admin_tools_path, alert: "Invalid API selected. Please choose from the supported APIs."
      return
    end

    result = External::VancouverCity::PurgeService.call(api_key: api_key)

    if result.success?
      discarded_count = result.data[:discarded_count] || 0
      redirect_to admin_facilities_path(service: "water_fountain"), notice: "#{discarded_count} facilities purged from #{External::ApiHelper.api_name(api_key)}."
    else
      error_messages = result.errors.join(", ")
      redirect_to admin_tools_path, alert: "Failed to purge facilities: #{error_messages}"
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
