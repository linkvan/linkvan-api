# frozen_string_literal: true

module Analytics
  class << self
    def find_or_create_visit_from(access_token, visit_params)
      Visit.find_or_initialize_by(
        uuid: access_token.uuid,
        session_id: access_token.session_id
      ).attempt_update_coordinates(visit_params)
    end

    def register_event(visit, event_params)
      visit.events.create!(event_params)
    end

    def register_analytics_impressions_for(event, impressionable_or_impressionables)
      return if impressionable_or_impressionables.blank?

      impressionables = if impressionable_or_impressionables.respond_to?(:each)
                          impressionable_or_impressionables
                        else
                          [impressionable_or_impressionables]
                        end

      impressions_params = impressionables.map do |impressionable|
        { impressionable_type: impressionable.class,
          impressionable_id: impressionable.id }
      end

      event.impressions.upsert_all(impressions_params, record_timestamps: true)
    end
  end
end
