# frozen_string_literal: true

class Analytics::Event < ApplicationRecord
  belongs_to :visit

  has_many :impressions, dependent: :destroy

  validates :controller_name, :action_name, :request_url, presence: true
end
