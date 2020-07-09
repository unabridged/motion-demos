# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_06_150357) do

  create_table "clicker_games", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_clicker_games_on_key", unique: true
  end

  create_table "clicker_players", force: :cascade do |t|
    t.integer "clicker_game_id", null: false
    t.string "name"
    t.integer "score", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clicker_game_id"], name: "index_clicker_players_on_clicker_game_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "from_id"
    t.integer "to_id"
    t.text "content"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["from_id"], name: "index_messages_on_from_id"
    t.index ["to_id"], name: "index_messages_on_to_id"
  end

  create_table "signups", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "favorite_color"
    t.integer "plan"
    t.boolean "terms"
    t.date "birthday"
    t.string "country"
    t.string "state"
    t.text "comments"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.integer "status", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "messages", "users", column: "from_id"
  add_foreign_key "messages", "users", column: "to_id"
end
