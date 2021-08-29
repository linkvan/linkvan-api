# frozen_string_literal: true

class ZoneSerializer < ApplicationSerializer
  def attributes
    fields = super
    fields += [:admins]
    fields
  end

  def admins
    object.users.select(:id, :name).as_json
  end
end
