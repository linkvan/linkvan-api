class Zone < ApplicationRecord
  has_many :facilities
  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :description, presence: true
end # /Zone
