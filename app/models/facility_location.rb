class FacilityLocation < ApplicationRecord
  include Localizable

  belongs_to :facility

  validates :latitude, :longitude, presence: true
  validates :address, :city, presence: true

  def data
    JSON.parse(data_raw || "", symbolize_names: true)
  rescue JSON::ParserError
    nil
  end

  def coordinates
    [latitude, longitude]
  end
end
