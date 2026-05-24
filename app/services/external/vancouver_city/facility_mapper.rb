# frozen_string_literal: true

class External::VancouverCity::FacilityMapper < ApplicationService
  attr_reader :record

  def initialize(record)
    super()
    @record = record
  end

  # Extract external_id or fallback to a generated ID using the provided prefix
  # @param record [Hash] API response record
  # @param prefix [String] Prefix to use if mapid is not present
  # @return [String] Generated external_id
  def self.external_id(record, prefix = nil)
    result = record["mapid"]
    generated_id = nil
    if result.blank? && prefix.present?
      generated_id = "#{prefix}-#{name(record)}".parameterize
      Rails.logger.warn "Record is missing 'mapid', generated external_id '#{generated_id}' using prefix '#{prefix}' and name '#{record['name']}'"
    end

    result.presence || generated_id
  end

  # Extract external_id
  # @param prefix [String] Prefix to use if mapid is not present
  # @return [String] Generated external_id
  def external_id(prefix)
    self.class.external_id(record, prefix)
  end

  # Extract facility name
  # @return [String, nil] Facility name
  def self.name(record)
    name = record["name"].to_s
    return nil if name.blank?

    strip_special_chars(name)
  end

  # Replace special characters with whitespace and clean up
  def self.strip_special_chars(value)
    value.to_s.gsub("\\n", " ").tr("\n", " ").gsub(/\s+/, " ").strip.presence
  end

  # Extract facility name
  # @return [String, nil] Facility name
  def name
    self.class.name(record)
  end

  # Extract address
  # @return [String, nil] Facility address
  def address
    # For drinking fountains, use the location field and geo_local_area
    location = self.class.strip_special_chars(record["location"])
    area = self.class.strip_special_chars(record["geo_local_area"])

    [location, area].compact.join(", ").presence
  end

  # Extract phone number
  # @return [String, nil] Phone number
  def phone
    record["phone"] || record["phone_number"] || record["contact_phone"]
  end

  # Extract website
  # @return [String, nil] Website URL
  def website
    record["website"] || record["url"] || record["web_site"]
  end

  # Extract notes/description
  # @return [String, nil] Notes or description
  def notes
    notes_parts = []

    # Include maintainer info
    notes_parts << "Maintained by: #{record['maintainer']}" if record["maintainer"].present?

    # Include operation info
    notes_parts << "Operation: #{record['in_operation']}" if record["in_operation"].present?

    # Include pet friendly info
    notes_parts << "Pet friendly: #{record['pet_friendly']}" if record["pet_friendly"].present?

    notes_parts.join(". ").presence
  end

  Coord = Struct.new(:lat, :long, keyword_init: true)

  # Extract coordinates from geometry
  # @return [Hash] Hash with :lat and :long keys
  def coordinates
    coords = record.dig("geom", "geometry", "coordinates").presence || []
    return {} unless coords.size == 2

    # GeoJSON coordinates are [longitude, latitude]
    Coord.new(lat: coords[1], long: coords[0])
  end

  # Extract coordinates from geo_point_2d
  # @return [Hash] Hash with :lat and :long keys
  def geo_point_2d
    geo_point = record["geo_point_2d"].presence || {}
    return {} unless geo_point.is_a?(Hash)
    return {} unless geo_point.key?("lat") && geo_point.key?("lon")

    Coord.new(lat: geo_point["lat"], long: geo_point["lon"])
  end
end
