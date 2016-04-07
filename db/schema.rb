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

ActiveRecord::Schema.define(version: 20160407183659) do

  create_table "players", force: true do |t|
    t.string   "rfid_hash"
    t.string   "name"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["rfid_hash"], name: "index_players_on_rfid_hash"

  create_table "rooms", force: true do |t|
    t.string   "client_token"
    t.integer  "team_a_score"
    t.integer  "team_b_score"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "game"
  end

  create_table "rooms_players", force: true do |t|
    t.integer "room_id"
    t.integer "player_id"
    t.string  "team",      limit: 5
  end

  add_index "rooms_players", ["player_id"], name: "index_rooms_players_on_player_id"
  add_index "rooms_players", ["room_id"], name: "index_rooms_players_on_room_id"

end
