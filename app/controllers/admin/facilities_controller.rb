# frozen_string_literal: true

class Admin::FacilitiesController < Admin::BaseController
  before_action :load_facilities, only: [:index]
  before_action :load_services_dropdown, only: [:index]
  before_action :load_welcomes_dropdown, only: [:index]
  before_action :load_facility, only: %i[show edit update destroy]

  def index; end

  def show; end

  def edit; end

  def update
    if @facility.update(facility_params)
      redirect_to [:admin, @facility], notice: "Successfully updated facility (id: #{@facility.id})"
    else
      flash.now[:alert] = "Failed to update facility (id: #{@facility.id}). Errors: #{@facility.errors.full_messages.join('; ')}"

      render action: :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @facility.destroy
      flash[:notice] = "Successfully deleted Facility #{@facility.name} (id: #{@facility.id}"
    else
      # Error when turning Welcome on.
      flash[:error] = "Failed to delete Facility #{@facility.name} (id: #{@facility.id}). Errors: #{@facility.errors.full_messages.join('; ')}"
    end

    redirect_back fallback_location: admin_facilities_path
  end

  private

  def load_facilities
    facilities = Facility.all

    case params[:status]
    when "live"
      facilities = facilities.live
    when "pending_reviews"
      facilities = facilities.pending_reviews
    end

    if params[:service_id] == "none"
      facilities = facilities.without_services
    elsif params[:service_id].present?
      facilities = facilities.joins(:services)
                             .where(services: { id: params[:service_id] })
    end

    if params[:welcome_customer] == "none"
      facilities = facilities.without_welcomes
    elsif params[:welcome_customer].present?
      facilities = facilities.joins(:facility_welcomes)
                             .where(facility_welcomes: { customer: params[:welcome_customer] })
    end

    if params[:q].present?
      facilities = facilities.name_search(params[:q]).or(
        facilities.address_search(params[:q])
      )
    end

    @pagy, @facilities = pagy(facilities)
  end

  def load_facility
    @facility = Facility.find(params[:id])
  end

  def load_services_dropdown
    @services_dropdown = [["No Services", :none]] + Service.pluck(:name, :id)
  end

  def load_welcomes_dropdown
    @welcomes_dropdown = [["No Welcomes", :none]] + FacilityWelcome.customers.map { |k, v| [k.titleize, v] }
  end

  def facility_params
    params.require(:facility).permit(:verified, :name, :phone, :website, :address, :lat, :long, :description, :notes)
  end
end
