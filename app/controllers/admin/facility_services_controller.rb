# frozen_string_literal: true

class Admin::FacilityServicesController < Admin::BaseController
  # before_action :set_default_request_format
  before_action :load_facility
  before_action :load_service
  before_action :load_facility_service

  def create
    if @facility_service.present?
      # Service already assigned
      flash[:notice] = "Facility #{@facility.name} (id: #{@facility.id}) already had #{@service.name} service turned on"
    elsif @facility.facility_services.create(service: @service)
      flash[:notice] = "Successfully turned on #{@service.name} service for Facility #{@facility.name} (id: #{@facility.id}"
    else
      # Service not assigned
      flash[:error] = "Failed to turn on #{@service.name} service for Facility #{@facility.name} (id: #{@facility.id}"
    end

    redirect_to admin_facility_path(id: params[:facility_id])
  end

  def update
    if @facility_service.blank?
      flash[:error] = "Facility #{@facility.name} (id: #{@facility.id}) doesn't have #{@service.name} turned on"
    elsif @facility_service.update(update_facility_service_params)
      flash[:notice] = "Successfully updated #{@service.name} service for Facility #{@facility.name} (id: #{@facility.id}"
    else
      flash[:error] = "Failed to update #{@service.name} service for Facility #{@facility.name} (id: #{@facility.id}"
    end

    redirect_to admin_facility_path(id: params[:facility_id])
  end

  def destroy
    if @facility_service.blank?
      # Service not assigned
      flash[:notice] = "Facility #{@facility.name} (id: #{@facility.id}) already had #{@service.name} service turned off"
    elsif @facility_service.destroy
      # Service assigned
      flash[:notice] = "Successfully turned off #{@service.name} service for Facility #{@facility.name} (id: #{@facility.id}"
    else
      # Service not assigned
      flash[:error] = "Failed to turn off #{@service.name} service for Facility #{@facility.name} (id: #{@facility.id}"
    end

    redirect_to admin_facility_path(id: params[:facility_id])
  end

  private

  def load_facility_service
    @facility_service = @facility.facility_services.find_by(service: @service)
  end

  def load_facility
    @facility = Facility.find(params[:facility_id])
  end

  def load_service
    @service = Service.find(params[:service_id])
  end

  def update_facility_service_params
    params.require(:facility_service).permit(:note)
  end
end
