# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Creates Services options provided by facilities.
Service.find_or_create_by(name: "Shelter")
Service.find_or_create_by(name: "Food")
Service.find_or_create_by(name: "Medical")
Service.find_or_create_by(name: "Hygiene")
Service.find_or_create_by(name: "Techonlogy")
Service.find_or_create_by(name: "Legal")
Service.find_or_create_by(name: "Learning")
Service.find_or_create_by(name: "Overdose Prevention")
Service.find_or_create_by(name: "Phone")

