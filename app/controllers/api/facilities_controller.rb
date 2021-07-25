class Api::FacilitiesController < Api::BaseController
  skip_before_action :require_signin

  # GET /facilities
  def index
    result = base_result

    @facilities = Facility.includes(:zone).is_verified.order(:updated_at)
    @facilities = @facilities.with_service(params[:service]) if params[:service].present?

    result[:facilities] = FacilitiesSerializer.new(@facilities, Facilities::IndexFacilitySerializer).build

    render json: result.as_json, status: :ok
  end

  # GET /facilities/:id
  def show
    result = base_result
    # result[:site_stats] = SiteStatsSerializer.new(SiteStats.new).build

    @facility = Facility.find(params[:id])
    result[:facility] = FacilitySerializer.new(@facility)

    render json: result.as_json, status: :ok
  end
end
