class FacilitiesController < ApplicationController
  skip_before_action :require_signin
  
  # GET /facilities
  def index
    @facilities = Facility.all #Facility.managed_by current_user

    @response = FacilitiesSerializer.new(@facilities)
    render json: @response, status: :ok
  end #/index

  # GET /facilities/:id
  def show
    @facility = Facility.find(params[:id])
    @response = FacilitySerializer.new(@facility)
    render json: @response, status: :ok
  end
end #/FacilitiesController
