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

ActiveRecord::Schema[8.0].define(version: 2025_02_07_162505) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "booking_extensions", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.integer "total_price_cents", default: 0, null: false
    t.string "total_price_currency", default: "MXN", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_booking_extensions_on_booking_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "car_id", null: false
    t.bigint "driver_id", null: false
    t.integer "total_price_cents", default: 0, null: false
    t.string "total_price_currency", default: "MXN", null: false
    t.integer "status", default: 0, null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_id"], name: "index_bookings_on_car_id"
    t.index ["driver_id"], name: "index_bookings_on_driver_id"
  end

  create_table "cars", force: :cascade do |t|
    t.string "brand", null: false
    t.bigint "user_id", null: false
    t.string "model", null: false
    t.string "year", null: false
    t.integer "status", default: 0, null: false
    t.integer "daily_rate_cents", default: 0, null: false
    t.string "daily_rate_currency", default: "MXN", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_cars_on_user_id"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "ticketable_type", null: false
    t.bigint "ticketable_id", null: false
    t.datetime "issue_date", null: false
    t.integer "rental_days", null: false
    t.integer "daily_rate_cents", default: 0, null: false
    t.string "daily_rate_currency", default: "MXN", null: false
    t.integer "subtotal_rent_cents", default: 0, null: false
    t.string "subtotal_rent_currency", default: "MXN", null: false
    t.integer "additional_charges_cents", default: 0, null: false
    t.string "additional_charges_currency", default: "MXN", null: false
    t.integer "discounts_cents", default: 0, null: false
    t.string "discounts_currency", default: "MXN", null: false
    t.integer "taxes_cents", default: 0, null: false
    t.string "taxes_currency", default: "MXN", null: false
    t.integer "total_amount_cents", default: 0, null: false
    t.string "total_amount_currency", default: "MXN", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticketable_type", "ticketable_id"], name: "index_tickets_on_ticketable"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.string "jti", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "booking_extensions", "bookings"
  add_foreign_key "bookings", "cars"
  add_foreign_key "bookings", "users", column: "driver_id"
  add_foreign_key "cars", "users"
end
