# frozen_string_literal: true

class Impression < ApplicationRecord
  belongs_to :event
  belongs_to :impressionable, polymorphic: true

  has_one :visit, through: :event

  validates :impressionable, presence: true
end
