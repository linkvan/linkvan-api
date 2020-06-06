class ZoneSerializer < ApplicationSerializer
  def as_json
    {
      id: @zone.id,
      name: @zone.name,
      description: @zone.description,
      users: admins
    }
  end

  def admins
    @zone.users.select(:id, :name).as_json
  end
end #/ZoneSerializer
