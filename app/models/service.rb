# frozen_string_literal: true

class Service < ApplicationRecord
  has_many :facility_services
  has_many :facilities, through: :facility_services

  validates :key, :name, presence: true, uniqueness: { case_sensitive: false }

  scope :name_search, ->(name_value) { where(arel_table[:name].matches("%#{name_value}%")) }

  scope :exact_search, lambda { |name_or_key|
    where(key: name_or_key)
      .or(where(name: name_or_key))
 }
end
