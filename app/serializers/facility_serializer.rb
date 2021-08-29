# frozen_string_literal: true

class FacilitySerializer < ApplicationSerializer
  def attributes
    fields = super
    fields -= Facility.schedule_fields
    fields += %i[zone schedule]
    fields
  end

  def zone
    return [] if object.zone.nil?

    z = object.zone
    { id: z.id, name: z.name }
  end

  def welcomes
    object.welcomes_list
  end # /welcomes

  def services
    object.services_list
  end # /services

  def schedule
    prefix = "schedule_"
    result = HashWithIndifferentAccess.new
    object.schedule.each_pair do |wday, schedule_data|
      result["#{prefix}#{wday}"] = schedule_data
    end
    result
  end
end
