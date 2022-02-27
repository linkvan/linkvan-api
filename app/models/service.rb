# frozen_string_literal: true

class Service < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :name_search, ->(name_value) { where(arel_table[:name].matches("%#{name_value}%")) }

  def code
    # name.split.underscore.join('_')
    name.underscore
  end
end
