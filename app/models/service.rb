# frozen_string_literal: true

class Service < ApplicationRecord
  validates :key, :name, presence: true, uniqueness: { case_sensitive: false }
end
