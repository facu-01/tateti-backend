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

ActiveRecord::Schema[7.0].define(version: 2022_05_31_031527) do
  create_table "games", force: :cascade do |t|
    t.json "table"
    t.integer "player_winner_id"
    t.integer "first_player_id"
    t.integer "status"
    t.integer "player1_id"
    t.integer "player2_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player1_id"], name: "index_games_on_player1_id"
    t.index ["player2_id"], name: "index_games_on_player2_id"
  end

  create_table "moves", force: :cascade do |t|
    t.integer "cell_index"
    t.integer "player_id"
    t.integer "game_id"
    t.integer "prev_move_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "cell_index"], name: "index_moves_on_game_id_and_cell_index", unique: true
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["player_id"], name: "index_moves_on_player_id"
    t.index ["prev_move_id"], name: "index_moves_on_prev_move_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "moves", "moves", column: "prev_move_id"
end
