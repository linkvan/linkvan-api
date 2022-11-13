# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# Create an admin user:
User.create_with(
  name: "Admin",
  password: "password",
  password_confirmation: "password",
  admin: true,
  verified: true
).find_or_create_by!(email: "admin@example.com")

# Creates Services options provided by facilities.
Service.create_with(key: 'shelter').find_or_create_by!(name: "Shelter")
Service.create_with(key: 'food').find_or_create_by!(name: "Food")
Service.create_with(key: 'medical').find_or_create_by!(name: "Medical")
Service.create_with(key: 'hygience').find_or_create_by!(name: "Hygiene")
Service.create_with(key: 'technology').find_or_create_by!(name: "Technology")
Service.create_with(key: 'legal').find_or_create_by!(name: "Legal")
Service.create_with(key: 'learning').find_or_create_by!(name: "Learning")
Service.create_with(key: 'overdoze_preventiion').find_or_create_by!(name: "Overdose Prevention")
Service.create_with(key: 'phone').find_or_create_by!(name: "Phone")

# Zones
Zone.create_with(description: "Vancouver city zone")
    .find_or_create_by!(name: 'Vancouver')
Zone.create_with(description: "New Westminster city zone")
    .find_or_create_by!(name: 'New Westminster')

facility_ids = Facility.all.ids

# Analytics Examples
1000.times.each do |n|
  created_at = rand(90).days.ago
  uuid = SecureRandom.hex
  session_id = SecureRandom.hex

  visit = Visit.create_with(created_at: created_at)
               .find_or_create_by!(uuid: uuid,
                                   session_id: session_id)
  created_at = visit.created_at

  rand(10).times.each do
    event_date = rand(120).minutes.after(created_at)
    event = visit.events.create!(controller_name: 'api/facilities',
                                action_name: 'index',
                                lat: Faker::Address.latitude,
                                long: Faker::Address.longitude,
                                ip_address: Faker::Internet.ip_v4_address,
                                created_at: event_date)


    n = rand(10) + 1
    ids_to_filter = facility_ids.sample(n)
    Facility.where(id: ids_to_filter).find_each do |facility|
      event.impressions.create!(impressionable: facility,
                                created_at: event_date)
    end
  end

  print "."
end