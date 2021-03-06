# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  def as_json
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      created_at: @user.created_at,
      updated_at: @user.updated_at,
      admin: @user.admin,
      activation_email_sent: @user.activation_email_sent,
      phone_number: @user.phone_number,
      verified: @user.verified,
      facilities: facilities,
      zones: zones
    }
  end

  def facilities
    @user.facilities.select(:id, :name).as_json
  end

  def zones
    @user.zones.select(:id, :name).as_json
  end
end # /ZoneSerializer
