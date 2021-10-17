# frozen_string_literal: true

class Admin::FacilitiesController < Admin::BaseController
  before_action :load_facilities, only: [:index]
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
    @pagy, @facilities = pagy(facilities)
  end

  def load_facility
    @facility = Facility.find(params[:id])
  end

  def facility_params
    params.require(:facility).permit(:verified, :name, :phone, :website, :address, :lat, :long, :description, :notes)
  end
end
