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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131015062107) do

  create_table "awards", :force => true do |t|
    t.string   "title"
    t.string   "code"
    t.float    "probability"
    t.integer  "count"
    t.integer  "game_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "awards", ["code"], :name => "index_awards_on_code"
  add_index "awards", ["game_id"], :name => "index_awards_on_game_id"

  create_table "games", :force => true do |t|
    t.string   "code"
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "games", ["code"], :name => "index_games_on_code"

  create_table "keywords", :force => true do |t|
    t.string   "title"
    t.string   "ancestry"
    t.boolean  "is_child",   :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "keywords", ["ancestry"], :name => "index_keywords_on_ancestry"

end
