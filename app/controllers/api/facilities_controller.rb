# frozen_string_literal: true

class Api::FacilitiesController < Api::BaseController
  # skip_before_action :authenticate_user!

  # GET /facilities
  def index
    result = base_result

    @facilities = Facility.includes(:zone).is_verified.order(:updated_at)
    @facilities = @facilities.with_service(params[:service]) if params[:service].present?

    result[:facilities] = []
    @facilities.each do |facility|
      serializer = FacilitySerializer.call(facility, complete: false)
      result[:facilities] << serializer.data
    end
    # result[:facilities] = FacilitiesSerializer.new(@facilities, Facilities::IndexFacilitySerializer).build

    # services
    # search => name, type, service, welcomes

    render json: result.as_json, status: :ok
  end

  # GET /facilities/:id
  def show
    result = base_result
    # result[:site_stats] = SiteStatsSerializer.new(SiteStats.new).build

    @facility = Facility.find(params[:id])
    result[:facility] = FacilitySerializer.call(@facility).data

    render json: result.as_json, status: :ok
  end
end
