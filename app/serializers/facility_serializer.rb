class FacilitySerializer < ApplicationSerializer
  def attributes
    fields = super
    fields -= Facility.schedule_fields
    fields += [:zone, :schedule]
    fields
  end

  def zone
    return [] if object.zone.nil?

    z = object.zone
    { id: z.id, name: z.name }
  end

  def welcomes
    return [] if object.welcomes.nil?

    object.welcome.underscores.split(' ')
  end #/welcomes

  def services
    return [] if object.services.nil?

    object.services.underscore.split(' ')
  end #/services

  def schedule
    prefix = 'schedule_'
    result = HashWithIndifferentAccess.new
    object.schedule.each_pair do |wday, schedule_data|
      result["#{prefix}#{wday}"] = schedule_data
    end
    result
  end
end #/FacilitySerializer
