# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161106130351) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "loads", force: :cascade do |t|
    t.date     "delivery_date"
    t.string   "delivery_shift"
    t.integer  "truck_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "orders_count",   default: 0, null: false
  end

  add_index "loads", ["truck_id"], name: "index_loads_on_truck_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.date     "delivery_date"
    t.string   "delivery_shift"
    t.string   "origin_name"
    t.string   "origin_address"
    t.string   "origin_city"
    t.string   "origin_state"
    t.string   "origin_zip"
    t.string   "origin_country"
    t.string   "client_name"
    t.string   "destination_address"
    t.string   "destination_city"
    t.string   "destination_state"
    t.string   "destination_zip"
    t.string   "destination_country"
    t.string   "phone_number"
    t.string   "mode"
    t.string   "purchase_order_number"
    t.float    "volume"
    t.integer  "handling_unit_quantity"
    t.string   "handling_unit_type"
    t.datetime "created_at",                                                                       null: false
    t.datetime "updated_at",                                                                       null: false
    t.integer  "delivery_order",         default: "nextval('order_delivery_order_seq'::regclass)", null: false
    t.integer  "load_id"
  end

  add_index "orders", ["delivery_order", "load_id"], name: "index_orders_on_delivery_order_and_load_id", unique: true, where: "((load_id IS NOT NULL) AND (delivery_order IS NOT NULL))", using: :btree
  add_index "orders", ["load_id"], name: "index_orders_on_load_id", using: :btree

  create_table "trucks", force: :cascade do |t|
    t.integer "user_id"
    t.integer "max_weight"
    t.integer "max_volume"
  end

  add_index "trucks", ["user_id"], name: "index_trucks_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "role"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

  add_foreign_key "loads", "trucks"
  add_foreign_key "orders", "loads"
  add_foreign_key "trucks", "users"
end
