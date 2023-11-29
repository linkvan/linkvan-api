require 'json'
require 'prophet-rb'
require 'rover'

class Admin::DashboardController < Admin::BaseController
  def index
  end

  def districts

    # https://gist.github.com/kidbrax/1236253

    # Read the JSON file
    json_file_path = Rails.root.join('lib', 'assets', 'local-area-boundary.json')
    polygons = []

    json_data = File.read(json_file_path)

    data = eval(json_data)  

    data.each do |row|
      points = []
      geom = row[:geom]
      geom[:geometry][:coordinates][0].each do |coord|
        points << [coord[0], coord[1]]
      end

      polygons << points
    end

  end

  # https://guides.rubyonrails.org/active_record_querying.html#retrieving-objects-from-the-database
  def timeseries
    impressions = Analytics::Visit.all

    visits_per_day = impressions.group_by_day(:created_at).count
    visits_per_day_transformed = visits_per_day.transform_keys { |date| date.strftime('%Y-%m-%d') }.to_a.map { |date, count| { 'ds' => date, 'y' => count } }
    df = Rover::DataFrame.new(visits_per_day_transformed)
    m = Prophet.new
    m.fit(df)
    future = m.make_future_dataframe(periods: 14)
    forecast = m.predict(future).to_a


   time_series_json = forecast.zip(visits_per_day_transformed).map do |forecast_row, visits_per_day_row|
     {
       date: forecast_row["ds"],
       pred: forecast_row["yhat"],
       actual: visits_per_day_row&.fetch("y", nil)
     }
   end
  
    render json: time_series_json
  end
  def heatmap
    data = {}
    # /admin/dashboard/heatmap?service=shelter
    if heatmap_params[:service].present?
      # Filter events by service
      # service = Service.find_by(key: heatmap_params[:service])
      # events = Analytics::Event.joins(impressions: :impressionables).where(impressionables: service.facilities)
    else
      events = Analytics::Event.all
    end

    events.find_each do |event|
      lat = event.lat
      long = event.long

      key = [lat, long]
      data[key] ||= { lat: lat, long: long, count: 0 }
      data[key][:count] += 1
    end

    geojson_data = {
      type: 'FeatureCollection',
      features: data.values.map do |value|
        {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [value[:long], value[:lat]]
          },
          properties: {
            count: value[:count]
          }
        }
      end
    }

    render json: geojson_data.to_json
  end

  private

  def heatmap_params
    params.permit(:service)
  end
end