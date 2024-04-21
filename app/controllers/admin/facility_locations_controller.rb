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

    respond_to do |format|
      if @facility.save
        success_msg = "Facility's address has been updated"
        success_path = admin_facility_path(@facility)
        format.turbo_stream do
          flash[:notice] = success_msg

          turbo_stream_redirect_to(success_path)
        end

        format.html do
          redirect_to success_path, notice: success_msg
        end
      else
        flash.now[:error] = location_params.inspect
        render :new, status: :unprocessable_entity
      end
    end
  end

  private

  # Redirects out of the turbo frame.
  # see: https://stackoverflow.com/questions/75738570/getting-a-turbo-frame-error-of-content-missing/75750578#75750578
  def turbo_stream_redirect_to(target_path)
    render turbo_stream: turbo_stream.action(:redirect, target_path)
  end

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
