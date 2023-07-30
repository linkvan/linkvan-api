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
Service.create_with(key: 'hygiene').find_or_create_by!(name: "Hygiene")
Service.create_with(key: 'technology').find_or_create_by!(name: "Technology")
Service.create_with(key: 'legal').find_or_create_by!(name: "Legal")
Service.create_with(key: 'learning').find_or_create_by!(name: "Learning")
Service.create_with(key: 'overdose_prevention').find_or_create_by!(name: "Overdose Prevention")
Service.create_with(key: 'phone').find_or_create_by!(name: "Phone")
Service.create_with(key: 'water_fountain').find_or_create_by!(name: "Water Fountain")

# Zones
Zone.create_with(description: "Vancouver city zone")
    .find_or_create_by!(name: 'Vancouver')
Zone.create_with(description: "New Westminster city zone")
    .find_or_create_by!(name: 'New Westminster')
