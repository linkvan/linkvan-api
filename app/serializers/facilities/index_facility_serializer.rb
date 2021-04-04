class Facilities::IndexFacilitySerializer < FacilitySerializer
  REMOVED_ATTRIBUTES = %w[welcomes address website description notes verified shelter_note food_note medical_note hygiene_note technology_note legal_note learning_note zone_id created_at r_pets r_id r_cart r_phone r_wifi user_id].freeze

  def attributes
    fields = super
    fields -= REMOVED_ATTRIBUTES
    fields
  end
end
