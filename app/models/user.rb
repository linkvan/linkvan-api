# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :facilities, dependent: :nullify
  has_and_belongs_to_many :zones

  validates :name, presence: true
  validates :email, presence: true,
                    format: /\A\S+@\S+\z/,
                    uniqueness: { case_sensitive: false }

  def self.authenticate(email, password)
    user = User.find_by(email: email)
    user&.authenticate(password)
  end

  def self.to_csv
    attributes = %w[id name email password_digest created_at updated_at admin activation_email_sent phone_number
                    verified]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  def manages
    return Facility.all if super_admin?
    return Facility.where(zone: zone_ids) if zone_admin?

    facilities
  end

  def manageable_users
    return User.all if super_admin?
    return collect_users if zone_admin?

    self
  end

  def can_manage?(user)
    # SuperAdmins can manage all users
    return true if super_admin?
    # Non-SuperAdmins can't manage themselves
    return false if id == user.id

    # Zone Admins can manage all users from zone (but themselves)
    zone_users.include?(user)
  end

  def super_admin?
    (admin && verified)
  end

  def zone_admin?
    (zones.any? && verified)
  end

  def facility_admin?
    (facilities.any? && verified)
  end

  def zone_users
    collect_users
  end

  def toggle_verified!
    update(verified: !verified)
  end

  private

  def collect_users_from(facilities)
    facilities.map(&:user)
  end

  def collect_facilities_from(zones)
    zones.map(&:facilities)
  end

  def collect_users
    facilities = collect_facilities_from(zones)
    collect_users_from(facilities).uniq
  end
end
