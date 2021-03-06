class User < ApplicationRecord
  has_secure_password
  has_many :facilities
  has_and_belongs_to_many :zones

  validates :name, presence: true
  validates :email, presence: true,
            format: /\A\S+@\S+\z/,
            uniqueness: { case_sensitive: false }

  def self.authenticate(email, password)
    user = User.find_by(email: email)
    user && user.authenticate(password)
  end

  def self.to_csv
    attributes = %w{id name email password_digest created_at updated_at admin activation_email_sent phone_number verified}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  def manages
    return Facility.all if self.super_admin?
    return Facility.where(zone: zone_ids) if self.zone_admin?
    self.facilities
  end

  def manageable_users
    return User.all if self.super_admin?
    return self.collect_users if self.zone_admin?
    self
  end

  def can_manage?(user)
    # SuperAdmins can manage all users
    return true if self.super_admin?
    # Non-SuperAdmins can't manage themselves
    return false if self.id == user.id
    # Zone Admins can manage all users from zone (but themselves)
    (zone_users.include?(user))
  end

  def super_admin?
    (self.admin && self.verified)
  end

  def zone_admin?
    (self.zones.any? && self.verified)
  end

  def facility_admin?
    (self.facilities.any? && self.verified)
  end

  def zone_users
    (self.collect_users)
  end

  def toggle_verified!
    self.update(verified: !self.verified)
  end

  private
    def collect_users_from(facilities)
      facilities.map(&:user)
    end

    def collect_facilities_from(zones)
      zones.map(&:facilities)
    end

    def collect_users
      facilities  = collect_facilities_from(self.zones)
      collect_users_from(facilities).uniq
    end
end
