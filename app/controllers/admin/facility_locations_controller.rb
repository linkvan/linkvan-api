# frozen_string_literal: true

class Admin::FacilityLocationsController < Admin::BaseController
  before_action :load_facility
  before_action :load_location
  before_action :search_and_load_locations

  def index
  end

  def new
  end

  def create
    @facility.assign_attributes(location_params)
    if @facility.save
      redirect_to [:admin, @facility], notice: "Facility's address has been updated"
    else
      flash.now[:error] = location_params.inspect
      render :new, status: :unprocessable_entity
    end
  end

  private

  def search_and_load_locations
    locations_result = if search_params[:q].present?
                         Locations::Searcher.call(address: search_params[:q])
                       else
                         []
                       end

    @locations = locations_result.to_a
  end

  def load_location
    @location = if @facility.present?
                  Location.build_from(facility: @facility)
                else
                  Location.build(location_params)
                end
  end

  def load_facility
    @facility = Facility.find(params[:facility_id])
  end

  def location_params
    params
      .require(:location)
      .permit(:address, :lat, :long)
  end

  def search_params
    params.permit(:q)
  end
end
