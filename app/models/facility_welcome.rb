# frozen_string_literal: true

class FacilityWelcome < ApplicationRecord
  belongs_to :facility

  validates :customer, presence: true, uniqueness: { scope: :facility }

  enum customer: {
    male: "male",
    female: "female",
    transgender: "transgender",
    children: "children",
    youth: "youth",
    adult: "adult",
    senior: "senior"
  }

  def name
    customer.to_s.titleize
  end

  def self.all_customers
    customers.values.map { |c| OpenStruct.new(name: c.to_s.titleize, value: c) }
  end

  def self.names
    all_customers.map(&:titleize)
  end
end
