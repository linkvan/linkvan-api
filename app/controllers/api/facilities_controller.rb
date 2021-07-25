class Api::FacilitiesController < Api::BaseController
  skip_before_action :require_signin
  
  # GET /facilities
  def index
    @facilities = Facility.includes(:zone).is_verified.order(:updated_at)
    @facilities = @facilities.with_service(params[:service]) if params[:service].present?

    @response = FacilitiesSerializer.new(@facilities, Facilities::IndexFacilitySerializer)

    render json: @response, status: :ok
  end

  # GET /facilities/:id
  def show
    @facility = Facility.find(params[:id])
    @response = { facility: FacilitySerializer.new(@facility).as_json }

    render json: @response, status: :ok
  end
end
