class Facilities::Location < ApplicationRecord
  include Localizable

  def data
    JSON.parse(data_raw, symbolize_names: true)
  end

  def coordinates
    [latitude, longitude]
  end
end
