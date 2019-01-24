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


ActiveRecord::Schema.define(version: 20190123185753) do

  create_table "bathrooms", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "token",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_heard_from_time"
  end

  create_table "daily_stats", force: :cascade do |t|
    t.integer "player_id"
    t.date    "day"
    t.boolean "has_completed_aggregation"
    t.integer "player_count"
    t.integer "wins"
    t.integer "losses"
    t.integer "most_defeated_player_id"
    t.integer "most_defeated_by_player_id"
    t.float   "average_win_margin"
    t.float   "average_loss_margin"
    t.integer "total_points_scored"
    t.integer "total_points_scored_against"
  end

  add_index "daily_stats", ["player_id", "day", "has_completed_aggregation", "player_count"], name: "daily_stats_lookup"
  add_index "daily_stats", ["player_id"], name: "index_daily_stats_on_player_id"

  create_table "game_histories", force: :cascade do |t|
    t.integer  "room_id"
    t.integer  "player_id"
    t.integer  "game_id"
    t.string   "game_session_id",     limit: 255
    t.integer  "player_count"
    t.integer  "player_team_score"
    t.integer  "opponent_team_score"
    t.boolean  "win"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "skill_change"
    t.float    "deviation_change"
    t.text     "team",                            default: ""
  end

  add_index "game_histories", ["game_id", "game_session_id"], name: "index_game_histories_on_game_id_and_game_session_id"
  add_index "game_histories", ["player_id", "win", "player_count"], name: "index_game_histories_on_player_id_and_win_and_player_count"
  add_index "game_histories", ["player_id"], name: "index_game_histories_on_player_id"
  add_index "game_histories", ["room_id"], name: "index_game_histories_on_room_id"

  create_table "players", force: :cascade do |t|
    t.string   "rfid_hash",        limit: 255
    t.string   "name",             limit: 255
    t.string   "image_url",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rating_skill",     default: 25.0
    t.float    "rating_deviation", default: 8.333333333333334
    t.string   "wallet",           limit: 255
    t.boolean  "is_archived",      default: false
    t.string   "pin",              default: "0000",            null: false
  end

  add_index "players", ["rfid_hash"], name: "index_players_on_rfid_hash"

  create_table "room_players", force: :cascade do |t|
    t.integer "room_id"
    t.integer "player_id"
    t.string  "team",          limit: 5
    t.integer "player_number"
  end

  add_index "room_players", ["player_id"], name: "index_room_players_on_player_id"
  add_index "room_players", ["room_id"], name: "index_room_players_on_room_id"

  create_table "rooms", force: :cascade do |t|
    t.string   "client_token",         limit: 255
    t.integer  "team_a_score"
    t.integer  "team_b_score"
    t.string   "name",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "game"
    t.integer  "player_count",                     default: 4,  null: false
    t.string   "game_session_id",      limit: 255
    t.datetime "increment_at"
    t.integer  "last_request_id"
    t.integer  "initial_serving_team",             default: 0
    t.integer  "streak",                           default: 0
    t.text     "streak_history",                   default: ""
  end

  create_table "score_histories", force: :cascade do |t|
    t.integer  "game_id"
    t.string   "team"
    t.integer  "score_change"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "stall_stats", force: :cascade do |t|
    t.datetime "usage_start"
    t.datetime "usage_end"
    t.integer  "stall_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stalls", force: :cascade do |t|
    t.integer  "bathroom_id"
    t.boolean  "state"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "weekly_stats", force: :cascade do |t|
    t.integer "player_id"
    t.date    "week_start"
    t.boolean "has_completed_aggregation"
    t.integer "player_count"
    t.integer "wins"
    t.integer "losses"
    t.integer "most_defeated_player_id"
    t.integer "most_defeated_by_player_id"
    t.float   "average_win_margin"
    t.float   "average_loss_margin"
    t.integer "total_points_scored"
    t.integer "total_points_scored_against"
  end

  add_index "weekly_stats", ["player_id", "week_start", "has_completed_aggregation", "player_count"], name: "weekly_stats_lookup"
  add_index "weekly_stats", ["player_id"], name: "index_weekly_stats_on_player_id"

end
