# frozen_string_literal: true

class Admin::ToolsController < Admin::BaseController
  before_action :enforce_admin_user

  def index; end

  def import_facilities
    api_key = params[:api]

    unless External::ApiHelper.supported_api?(api_key)
      redirect_to admin_tools_path, alert: "Invalid API selected. Please choose from the supported APIs."
      return
    end

    result = External::VancouverCity::Syncer.call(
      api_key: api_key,
      api_client: External::VancouverCity.default_client,
      full_sync: true
    )

    result_data = collect_result_data(result)
    handle_import_result(result, result_data, api_key)
  end

  def discard_facilities
    successes = 0
    errors = []
    Facility.external.kept.find_each do |facility|
      result = External::VancouverCity::FacilityDiscarder.call(facility)
      if result.success?
        successes += 1
      else
        Rails.logger.error "Failed to discard facility #{facility.id} (#{facility.name}): #{result.errors.join(', ')}"
        errors << result.error_messages
      end
    end

    handle_discard_result(successes, errors)
  end

  def handle_discard_result(successes, errors)
    if errors.empty?
      Rails.logger.info "Successfully discarded #{successes} external facilities."
      redirect_to admin_facilities_path(service: "water_fountain"),
                  notice: "#{successes} external facilities discarded."
    elsif successes.positive?
      Rails.logger.warn "Partial discard: #{successes} facilities discarded, but #{errors.flatten.size} failed to discard with errors: #{errors.flatten.join('; ')}"
      success_message = "#{successes} external facilities discarded."
      failure_message = "However, #{errors.flatten.size} facilities failed to discard with errors: #{errors.flatten.join('; ')}"
      redirect_to admin_tools_path(service: "water_fountain"),
                  alert: "#{success_message} #{failure_message}."
    else
      Rails.logger.error "Failed to discard any facilities. Errors: #{errors.flatten.join('; ')}"
      error_messages = errors.flatten.join("; ")
      redirect_to admin_tools_path, alert: "Failed to discard #{errors.size} facilities: #{error_messages}"
    end
  end

  SyncReport = Struct.new(
    :create_operation, :update_operation, :delete_operation,
    :success_count, :failure_count,
    :success_created, :success_updated, :success_deleted,
    :failure_created, :failure_updated, :failure_deleted,
    :errors_messages,
    keyword_init: true
  )

  # Helper method for the view
  helper_method :api_options_for_select

  private

  def collect_result_data(sync_result)
    create_op = sync_result.data.select { |e| e.operation == External::SyncOperations.create }
    update_op = sync_result.data.select { |e| e.operation.name == "update" }
    delete_op = sync_result.data.select { |e| e.operation == External::SyncOperations.discard }

    SyncReport.new(
      create_operation: create_op,
      update_operation: update_op,
      delete_operation: delete_op,
      success_count: sync_result.data.count(&:success?),
      failure_count: sync_result.data.count(&:failed?),
      success_created: create_op.count(&:success?),
      success_updated: update_op.count(&:success?),
      success_deleted: delete_op.count(&:success?),
      failure_created: create_op.count(&:failed?),
      failure_updated: update_op.count(&:failed?),
      failure_deleted: delete_op.count(&:failed?),
      errors_messages: sync_result.errors.flatten
    )
  end

  def handle_import_result(result, result_data, api_key)
    if result.partial_failed?
      handle_partial_failure(result_data, api_key)
    elsif result.success?
      handle_full_success(result_data, api_key)
    else
      handle_full_failure(result_data, api_key)
    end
  end

  def handle_partial_failure(result_data, _api_key)
    Rails.logger.warn "Partial sync: #{result_data.success_count} facilities synced successfully, but #{result_data.failure_count} failed with errors: #{result_data.errors_messages.join(', ')}"
    redirect_to admin_tools_path, alert: "Sync completed with some errors: #{result_data.success_count} succeeded (#{result_data.success_created} created, #{result_data.success_updated} updated, #{result_data.success_deleted} deleted), but #{result_data.failure_count} failed (#{result_data.failure_created} create failures, #{result_data.failure_updated} update failures, #{result_data.failure_deleted} delete failures). Please check logs for details."
  end

  def handle_full_success(result_data, api_key)
    Rails.logger.info "Successfully imported #{result_data.success_count} facilities (#{result_data.success_created} created, #{result_data.success_updated} updated, #{result_data.success_deleted} deleted) from #{api_key} API."
    redirect_to admin_facilities_path(service: "water_fountain"), notice: "Successfully imported #{result_data.success_count} facilities (#{result_data.success_created} created, #{result_data.success_updated} updated, #{result_data.success_deleted} deleted) from #{api_key} API."
  end

  def handle_full_failure(result_data, api_key)
    Rails.logger.error "Failed to sync facilities from #{api_key} API: #{result_data.errors_messages.join(', ')}"
    redirect_to admin_tools_path, alert: "Failed to sync facilities from #{api_key} API: #{result_data.errors_messages.join(', ')}"
  end

  def api_options_for_select
    External::ApiHelper.api_options
  end

  def enforce_admin_user
    redirect_to root_path, alert: "Access denied! You must be an admin to access tools" unless current_user&.admin?
  end
end
