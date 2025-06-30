# frozen_string_literal: true

require "ostruct"
require "bigdecimal"
require "bigdecimal/util"

class Facility < ApplicationRecord
  include Discardable

  belongs_to :user, optional: true
  belongs_to :zone, optional: true

  has_many :facility_welcomes, dependent: :destroy
  has_many :facility_services, dependent: :destroy
  has_many :services, through: :facility_services
  has_many :schedules, class_name: "FacilitySchedule", dependent: :destroy
  has_many :time_slots, through: :schedules

  enum :discard_reason, {
    none: nil,
    closed: "closed",
    duplicated: "duplicated"
  }, prefix: true, default: :none

  validates :name, presence: true

  with_options if: :verified? do |verified_facility|
    verified_facility.validates :lat, :long, presence: true
  end

  before_validation :clean_data
  # is_impressionable

  scope :live, -> { kept.is_verified }
  scope :is_verified, -> { where(verified: true) }
  scope :pending_reviews, -> { kept.where(verified: false) }
  scope :name_search, ->(name) { where(arel_table[:name].matches("%#{name}%")) }
  scope :address_search, ->(value) { where(arel_table[:address].matches("%#{value}%")) }
  scope :with_service, ->(service_key_or_name) { joins(:services).where(services: Service.exact_search(service_key_or_name)) }
  scope :without_services, -> { where.not(facility_services: FacilityService.all) }
  scope :without_welcomes, -> { where.not(facility_welcomes: FacilityWelcome.all) }
  scope :external, -> { where.not(external_id: nil) }
  scope :not_external, -> { where(external_id: nil) }

  def managed_by?(user)
    f_user_id = if user.respond_to? :id
      user.id
    else
      user
    end
    # Case Facility's User is the same
    return true if this.user_id == f_user_id
    # Case Zone of the Facility has the user as admin
    return true if User.find(f_user_id).manages.any?

    # Otherwise return FALSE
    false
  end

  def self.managed_by(user)
    user.manages
  end

  def self.adjusted_current_time
    # Returns current server time subtracted by 8 hours.
    8.hours.ago
  end

  def self.statuses
    %i[live pending_reviews discarded]
  end

  def status
    if discarded?
      :discarded
    elsif verified?
      :live
    else
      :pending_reviews
    end
  end

  def update_status(new_status)
    case new_status.to_sym
    when :live
      assign_attributes(verified: true)
    when :pending_reviews
      assign_attributes(verified: false)
    end

    save
  end

  def website_url
    return nil if website.blank?

    if URI.parse(website).scheme.present?
      website
    else
      "https://#{website}"
    end
  end

  def coordinates
    [lat, long]
  end

  def coord
    GeoLocation.coord(lat, long)
  end

  def distance(to_coord = nil, to_lat: nil, to_long: nil, to_facility: nil)
    to_coord = to_facility.coord if to_facility.respond_to?(:coord) && to_coord.blank?
    to_coord = GeoLocation.coord(to_lat, to_long) if to_coord.blank?

    GeoLocation.distance(coord, to_coord)
  end

  def distance_in_meters(*params)
    distance(*params).to_meters
  end

  def distance_in_kms(*params)
    distance(*params).to_kilometers
  end

  private

  def clean_data
    # strips whitespaces from beginning and end
    %i[name phone website address].each do |attrb|
      # squish (ActiveSupport's more in-depth strip whitespaces)
      send("#{attrb}=", send(attrb)&.squish)
    end

    %i[notes].each do |attrb|
      send("#{attrb}=", send(attrb)&.strip)
    end

    # handles discard
    self.discard_reason = :none if undiscarded?
  end
end
