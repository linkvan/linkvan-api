# frozen_string_literal: true

class Admin::FacilitiesController < Admin::BaseController
  before_action :load_facilities, only: [:index]
  before_action :load_services_dropdown, only: [:index]
  before_action :load_welcomes_dropdown, only: [:index]
  before_action :load_facility, only: %i[show edit update destroy]

  def index; end

  def show; end

  def edit; end

  def new
    @facility = Facility.new(
      zone: current_user.zones.first
    )
  end

  def create
    @facility = Facility.new(new_facility_params)

    if @facility.save
      redirect_to [:admin, @facility], notice: "Successfully created facility (id: #{@facility.id})"
    else
      flash.now[:alert] = "Failed to create facility. Errors: #{@facility.errors.full_messages.join('; ')}"

      render action: :new, status: :unprocessable_entity
    end
  end

  def update
    if params[:undiscard].present?
      if @facility.undiscard
        redirect_to [:admin, @facility], notice: "Successfully undiscarded facility (id: #{@facility.id})"
      else
        redirect_to [:admin, @facility], notice: "Failed to undiscarded facility (id: #{@facility.id}). Errors: #{@facility.errors.full_messages}"
      end
    elsif @facility.update(facility_params)
      redirect_to [:admin, @facility], notice: "Successfully updated facility (id: #{@facility.id})"
    else
      flash.now[:alert] = "Failed to update facility (id: #{@facility.id}). Errors: #{@facility.errors.full_messages.join('; ')}"

      render action: :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facility.assign_attributes(discard_facility_params)

    if @facility.discard
      flash[:notice] = "Successfully discarded Facility #{@facility.name} (id: #{@facility.id})"
      redirect_back fallback_location: admin_facility_path(@facility)
    else
      # Error when turning Welcome on.
      flash[:error] = "Failed to discard Facility #{@facility.name} (id: #{@facility.id}). Errors: #{@facility.errors.full_messages.join('; ')}"
      render action: :show, status: :unprocessable_entity
    end
  end

  private

  def load_facilities
    facilities = Facility.all

    case params[:status]
    when "live"
      facilities = facilities.live
    when "pending_reviews"
      facilities = facilities.pending_reviews
    when "discarded"
      facilities = facilities.discarded
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

  def new_facility_params
    facility_params.merge(user: current_user)
  end

  def facility_params
    params.require(:facility).permit(:verified, :name, :phone, :website, :address, :lat, :long, :description, :notes)
  end

  def discard_facility_params
    params.require(:facility).permit(:discard_reason)
  end
end
