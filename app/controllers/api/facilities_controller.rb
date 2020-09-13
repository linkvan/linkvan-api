class Api::FacilitiesController < Api::BaseController
  skip_before_action :require_signin
  
  # GET /facilities
  def index
    @facilities = Facility.includes(:zone).is_verified.order(:updated_at)

    @response = FacilitiesSerializer.new(@facilities, Facilities::IndexFacilitySerializer)
    render json: @response, status: :ok
  end #/index

  # GET /facilities/:id
  def show
    @facility = Facility.find(params[:id])
    @response = FacilitySerializer.new(@facility)
    render json: @response, status: :ok
  end
end #/FacilitiesController
