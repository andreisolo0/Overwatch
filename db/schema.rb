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

ActiveRecord::Schema.define(version: 2022_05_18_143147) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_alerts", force: :cascade do |t|
    t.string "host_item_id"
    t.string "item_id"
    t.string "threshold"
    t.string "severity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "new", default: true
    t.boolean "resolved", default: false
    t.integer "host_id"
    t.datetime "resolved_at"
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.integer "user_id"
  end

  create_table "host_items", force: :cascade do |t|
    t.bigint "host_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "value"
    t.string "threshold_high"
    t.string "threshold_warning"
    t.string "threshold_low"
    t.string "active_high_id"
    t.string "active_warning_id"
    t.string "active_low_id"
    t.string "alert_name_high"
    t.string "alert_name_warning"
    t.string "alert_name_low"
    t.integer "recovery_high"
    t.integer "recovery_warning"
    t.integer "recovery_low"
    t.index ["host_id"], name: "index_host_items_on_host_id"
    t.index ["item_id"], name: "index_host_items_on_item_id"
  end

  create_table "hosts", force: :cascade do |t|
    t.string "hostname"
    t.string "ip_address_or_fqdn"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.string "user_to_connect"
    t.string "password"
    t.integer "ssh_port"
    t.boolean "run_as_sudo"
    t.string "os"
    t.boolean "online"
    t.integer "assigned_items_host", default: [], array: true
    t.boolean "autopatch"
    t.boolean "reboot_required"
  end

  create_table "items", force: :cascade do |t|
    t.string "item_name"
    t.string "interval_to_read"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "command_to_read"
    t.text "description"
  end

  create_table "remote_actions", force: :cascade do |t|
    t.string "action_name"
    t.text "command_or_script"
    t.text "path_to_script"
    t.boolean "script"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "result_of_command"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
    t.boolean "admin"
    t.boolean "regular_user"
    t.boolean "viewer"
    t.string "first_name"
    t.string "last_name"
  end

  add_foreign_key "host_items", "hosts"
  add_foreign_key "host_items", "items"
end
