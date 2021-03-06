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

ActiveRecord::Schema.define(version: 20180224054360) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clockface_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "clockface_task_id"
    t.boolean "enabled", default: false
    t.boolean "skip_first_run", default: false
    t.string "tenant"
    t.datetime "last_triggered_at"
    t.integer "period_value", null: false
    t.string "period_units", null: false
    t.integer "day_of_week"
    t.integer "hour"
    t.integer "minute"
    t.string "time_zone"
    t.string "if_condition"
    t.index ["clockface_task_id"], name: "index_clockface_events_on_clockface_task_id"
  end

  create_table "clockface_tasks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.text "description"
    t.string "command", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "role"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "clockface_events", "clockface_tasks"
end
