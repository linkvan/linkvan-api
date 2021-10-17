# frozen_string_literal: true

class Zone < ApplicationRecord
  has_many :facilities, dependent: :nullify
  has_and_belongs_to_many :users # rubocop:disable Rails/HasAndBelongsToMany

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :description, presence: true
end
