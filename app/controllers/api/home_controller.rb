# frozen_string_literal: true

class Api::HomeController < Api::BaseController
  skip_before_action :require_signin

  def index
    result = {}

    alert = Alert.active.timeline.first
    result[:alert] = alert.nil? ? nil : AlertSerializer.new(alert).as_json

    result[:notices] = compute_notices

    result[:site_stats] = SiteStatsSerializer.new(SiteStats.new).build

    facilities = Facility.includes(:zone).is_verified.order(:updated_at)
    result[:facilities] = FacilitiesSerializer.new(facilities, Facilities::IndexFacilitySerializer).build

    # result[:notices] = 
    render json: result.as_json, status: :ok
  end

  def last_updated
  end

  private

  def compute_notices
    result = {}

    Notice.notice_types.each_key do |type|
      result[type] = Notice.published.where(notice_type: type).exists?
    end

    result
  end
end
