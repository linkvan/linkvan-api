# frozen_string_literal: true

class Admin::DashboardController < Admin::BaseController
  def index
  end

  def heatmap
    data = {}
    # /admin/dashboard/heatmap?service=shelter
    if heatmap_params[:service].present?
      # Filter events by service
      #service = Service.find_by(key: heatmap_params[:service])
      #events = Analytics::Event.joins(impressions: :impressionables).where(impressionables: service.facilities)
    else
      events = Analytics::Event.all
    end

    events.find_each do |event|
      lat = event.lat
      long = event.long
     
      key = [lat, long]
      data[key] ||= { lat:, long:, count: 0 }
      data[key][:count] += 1
    end

    render json: { data: data.values }
 end

  private

  def heatmap_params
    params.permit(:service)
  end
end
