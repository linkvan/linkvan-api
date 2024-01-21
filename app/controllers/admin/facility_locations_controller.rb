# frozen_string_literal: true

class Admin::FacilityLocationsController < Admin::BaseController
  # before_action :set_default_request_format
  before_action :load_facility#, only: %i[new, index]
  before_action :load_location#, only: %i[new, index]

  def index
    locations_result = if search_params[:q].present?
                         Locations::Searcher.call(address: search_params[:q])
                       else
                         []
                       end

    @locations = locations_result.to_a
  end

  def new
    # @location = Location.build_from(facility: @facility)
  end

  # def edit
  # end

  private

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
    params.permit(:address, :city, :lat, :long)
  end

  def search_params
    params.permit(:q)
  end
end
