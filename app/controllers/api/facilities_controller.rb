# frozen_string_literal: true

class Api::FacilitiesController < Api::BaseController
  # skip_before_action :authenticate_user!

  # GET /facilities
  def index
    result = base_result

    @facilities = Facility.is_verified.order(:updated_at)
    @facilities = @facilities.with_service(params[:service]) if params[:service].present?

    # Includes related objects to avoid N+1 queries
    @facilities = @facilities.includes(
      :zone,
      :schedules,
      :time_slots,
      :services,
      :facility_welcomes,
      :facility_services
    )

    result[:facilities] = []
    @facilities.each do |facility|
      serializer = FacilitySerializer.call(facility, complete: false)
      result[:facilities] << serializer.data
    end

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
