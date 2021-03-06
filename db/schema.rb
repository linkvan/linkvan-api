# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_01_190143) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alerts", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "analytics", id: :serial, force: :cascade do |t|
    t.string "sessionID"
    t.datetime "time"
    t.string "cookieID"
    t.string "service", null: false
    t.decimal "lat", null: false
    t.decimal "long", null: false
    t.decimal "facility"
    t.boolean "dirClicked", default: false
    t.string "dirType"
  end

  create_table "anaylitics", id: :serial, force: :cascade do |t|
    t.decimal "lat"
    t.decimal "long"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facilities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "welcomes"
    t.string "services"
    t.decimal "lat"
    t.decimal "long"
    t.string "address"
    t.string "phone"
    t.string "website"
    t.text "description"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time "startsmon_at"
    t.time "endsmon_at"
    t.time "startstues_at"
    t.time "endstues_at"
    t.time "startswed_at"
    t.time "endswed_at"
    t.time "startsthurs_at"
    t.time "endsthurs_at"
    t.time "startsfri_at"
    t.time "endsfri_at"
    t.time "startssat_at"
    t.time "endssat_at"
    t.time "startssun_at"
    t.time "endssun_at"
    t.boolean "r_pets", default: false
    t.boolean "r_id", default: false
    t.boolean "r_cart", default: false
    t.boolean "r_phone", default: false
    t.boolean "r_wifi", default: false
    t.time "startsmon_at2"
    t.time "endsmon_at2"
    t.time "startstues_at2"
    t.time "endstues_at2"
    t.time "startswed_at2"
    t.time "endswed_at2"
    t.time "startsthurs_at2"
    t.time "endsthurs_at2"
    t.time "startsfri_at2"
    t.time "endsfri_at2"
    t.time "startssat_at2"
    t.time "endssat_at2"
    t.time "startssun_at2"
    t.time "endssun_at2"
    t.boolean "open_all_day_mon"
    t.boolean "open_all_day_tues"
    t.boolean "open_all_day_wed"
    t.boolean "open_all_day_thurs"
    t.boolean "open_all_day_fri"
    t.boolean "open_all_day_sat"
    t.boolean "open_all_day_sun"
    t.boolean "closed_all_day_mon"
    t.boolean "closed_all_day_tues"
    t.boolean "closed_all_day_wed"
    t.boolean "closed_all_day_thurs"
    t.boolean "closed_all_day_fri"
    t.boolean "closed_all_day_sat"
    t.boolean "closed_all_day_sun"
    t.boolean "second_time_mon", default: false
    t.boolean "second_time_tues", default: false
    t.boolean "second_time_wed", default: false
    t.boolean "second_time_thurs", default: false
    t.boolean "second_time_fri", default: false
    t.boolean "second_time_sat", default: false
    t.boolean "second_time_sun", default: false
    t.integer "user_id"
    t.boolean "verified", default: false
    t.text "shelter_note"
    t.text "food_note"
    t.text "medical_note"
    t.text "hygiene_note"
    t.text "technology_note"
    t.text "legal_note"
    t.text "learning_note"
    t.integer "zone_id"
    t.index ["user_id"], name: "index_facilities_on_user_id"
    t.index ["zone_id"], name: "index_facilities_on_zone_id"
  end

  create_table "impressions", id: :serial, force: :cascade do |t|
    t.string "impressionable_type"
    t.integer "impressionable_id"
    t.integer "user_id"
    t.string "controller_name"
    t.string "action_name"
    t.string "view_name"
    t.string "request_hash"
    t.string "ip_address"
    t.string "session_hash"
    t.text "message"
    t.text "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index"
    t.index ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index"
    t.index ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index"
    t.index ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index"
    t.index ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index"
    t.index ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index"
    t.index ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index"
    t.index ["user_id"], name: "index_impressions_on_user_id"
  end

  create_table "listed_options", id: :serial, force: :cascade do |t|
    t.integer "analytic_id"
    t.string "sessionID", null: false
    t.datetime "time", null: false
    t.string "facility", null: false
    t.decimal "position", null: false
    t.decimal "total", null: false
    t.index ["analytic_id"], name: "index_listed_options_on_analytic_id"
  end

  create_table "notices", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "content"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fid"
    t.string "changetype"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "admin", default: false
    t.boolean "activation_email_sent", default: false
    t.string "phone_number"
    t.boolean "verified", default: false
  end

  create_table "users_zones", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "zone_id", null: false
    t.index ["user_id", "zone_id"], name: "index_users_zones_on_user_id_and_zone_id"
    t.index ["zone_id", "user_id"], name: "index_users_zones_on_zone_id_and_user_id"
  end

  create_table "zones", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "facilities", "zones"
end
