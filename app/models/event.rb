# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :visit

  has_many :impressions, dependent: :destroy

  validates :controller_name, presence: true
  validates :action_name, presence: true
end
