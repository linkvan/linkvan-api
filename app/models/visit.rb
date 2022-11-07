# frozen_string_literal: true

class Visit < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :impressions, through: :events

  validates :uuid, presence: true
  validates :session_id, presence: true, uniqueness: { scope: :uuid }

  def self.find_or_create_from(access_token)
    Visit.find_or_create_by(uuid: access_token.uuid,
                            session_id: access_token.session_id)
  end
end
