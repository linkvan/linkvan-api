# frozen_string_literal: true

class Alert < ApplicationRecord
  validates :title, :content, presence: true

  scope :timeline, -> { order(updated_at: :desc) }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
end
