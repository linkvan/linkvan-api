# frozen_string_literal: true

class Api::FacilitiesController < Api::BaseController
  # skip_before_action :authenticate_user!
  before_action :load_facilities, only: :index
  before_action :load_facility, only: :show
  before_action :register_impressions

  # GET /facilities
  def index
    result = base_result

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

    result[:facility] = FacilitySerializer.call(@facility).data

    render json: result.as_json, status: :ok
  end

  private

  def load_facility
    @facility = Facility.find(params[:id])
  end

  def load_facilities
    # Returns no facilities when parameters are missing to avoid overwhelming the server.
    # TODO: Properly implement pagination which will require working out distance calculations and sorting.
    if search_params.values.all?(:blank?)
      @facilities = Facility.none

      return
    end

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
    end

    # Includes related objects to avoid N+1 queries
    @facilities = @facilities.includes(
      :zone,
      :facility_welcomes,
      { facility_services: [:service] },
      { schedules: [:time_slots] }
    )
  end

  def register_impressions
    return if @facility.blank?

    # This is saving the analytics data synchronously. If performance proves to be an issue,
    #   we might need to move it to an ActiveJob.
    Analytics.register_analytics_impressions_for(event, @facility)
  end

  def search_params
    params.permit(:service, :search)
  end
end
