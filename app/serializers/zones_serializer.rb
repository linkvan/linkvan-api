class ZonesSerializer < ApplicationCollectionSerializer
  def as_json
    @zones.map do |zone|
      ZoneSerializer.new(zone).as_json
    end
  end
end #/ZoneSerializer
