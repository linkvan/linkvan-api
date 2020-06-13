namespace :data do
  # Usage Example:
  #    rake json:export[./db/facilities.json]
  desc "export active facilities to a JSON file"
  task load_fake: :environment do
    logger = Rails.logger
    logger.extend(ActiveSupport::Logger.broadcast(ActiveSupport::Logger.new(STDOUT)))
    logger.formatter = nil

    logger.info "[load_fake] Loading new facilities from database."
    new_facilities = load_fake_data.dig('v1', 'facilities')
    if new_facilities.blank?
      logger.error "[load_fake] Failed to load new facilities."
      abort
    end

    logger.info "[load_fake] Removing old facilities from database."
    result = Facility.all.map(&:destroy)
    unless result.all?
      logger.error "[load_fake] Failed to remove facilities."
      abort
    end

    logger.info "[load_fake] Creating #{new_facilities.count} facilities."
    result = new_facilities.map { |facility_hash| Facility.create(facility_hash) }
    logger.error "[load_fake] Failed to add facilities." unless result.all?

    logger.info "[load_fake] Done creating facilities."
  end
  
  def load_fake_data
    json_data_location = Rails.root.join('db', 'fake_data.json')
    JSON.load(json_data_location)
  end
end
