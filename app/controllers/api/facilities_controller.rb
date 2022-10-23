# frozen_string_literal: true

class Api::FacilitiesController < Api::BaseController
  # skip_before_action :authenticate_user!

  # GET /facilities
  def index
    result = base_result

    @facilities = Facility.undiscarded.is_verified.order(:updated_at)
    @facilities = @facilities.with_service(search_params[:service]) if search_params[:service].present?

    if search_params[:search].present?
      base_facilities = @facilities
      @facilities = base_facilities.name_search(search_params[:search])

      translation = Translator.call(search_params[:search]).data
      if translation.present?
        @facilities = @facilities.or(
          base_facilities.where(facility_welcomes: FacilityWelcome.name_search(translation))
        ).or(
          base_facilities.where(facility_services: FacilityService.name_search(translation))
        )
      end

      # Includes related objects to avoid N+1 queries
      @facilities = @facilities.includes(
        :zone,
        :schedules,
        :time_slots,
        :services,
        :facility_welcomes,
        :facility_services
      )
    end

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

  private

  def search_params
    params.permit(:service, :search)
  end
end
