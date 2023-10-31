# frozen_string_literal: true

class Analytics::Event < ApplicationRecord
  belongs_to :visit

  has_many :impressions, dependent: :destroy
  has_many :impressionables, through: :impressions, source: :impressionable

  has_many :facilities, through: :impressions,
                        source: :impressionable,
                        source_type: "Facility"

  validates :controller_name, :action_name, :request_url, presence: true
end
