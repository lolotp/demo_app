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

ActiveRecord::Schema.define(:version => 20140419073130) do

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comments", ["post_id", "user_id", "created_at"], :name => "index_comments_on_post_id_and_user_id_and_created_at"
  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "concierge_apps", :force => true do |t|
    t.string   "iso_country_code"
    t.string   "category"
    t.string   "app_store_link"
    t.string   "google_play_link"
    t.string   "link"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "concierge_apps", ["iso_country_code", "category"], :name => "index_concierge_apps_on_iso_country_code_and_category", :unique => true
  add_index "concierge_apps", ["iso_country_code"], :name => "index_concierge_apps_on_iso_country_code"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "dungeons", :force => true do |t|
    t.string   "description"
    t.string   "file_url"
    t.integer  "user_id"
    t.integer  "view_count"
    t.integer  "like_count"
    t.integer  "rating"
    t.float    "longitude"
    t.float    "latitude"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "dungeons", ["user_id", "created_at"], :name => "index_dungeons_on_user_id_and_created_at"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "follows", :force => true do |t|
    t.integer  "user_id"
    t.integer  "followee_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "follows", ["followee_id"], :name => "index_follows_on_followee_id"
  add_index "follows", ["user_id", "followee_id"], :name => "index_follows_on_user_id_and_followee_id", :unique => true
  add_index "follows", ["user_id"], :name => "index_follows_on_user_id"

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "status"
  end

  add_index "friendships", ["friend_id"], :name => "index_friendships_on_friend_id"
  add_index "friendships", ["status"], :name => "index_friendships_on_status"
  add_index "friendships", ["user_id", "friend_id"], :name => "index_friendships_on_user_id_and_friend_id", :unique => true
  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"

  create_table "landmarks", :force => true do |t|
    t.text     "description"
    t.string   "file_url"
    t.integer  "user_id"
    t.integer  "view_count",  :default => 0
    t.integer  "like_count",  :default => 0
    t.integer  "rating"
    t.float    "longitude",   :default => 0.0
    t.float    "latitude",    :default => 0.0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "name"
    t.string   "category",    :default => "Others"
  end

  add_index "landmarks", ["name"], :name => "index_landmarks_on_name"
  add_index "landmarks", ["user_id", "created_at"], :name => "index_landmarks_on_user_id_and_created_at"

  create_table "microposts", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "microposts", ["user_id", "created_at"], :name => "index_microposts_on_user_id_and_created_at"

  create_table "notifications", :force => true do |t|
    t.string   "content"
    t.boolean  "viewed",      :default => false
    t.integer  "receiver_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "notifications", ["created_at"], :name => "index_notifications_on_created_at"
  add_index "notifications", ["receiver_id"], :name => "index_notifications_on_receiver_id"
  add_index "notifications", ["viewed"], :name => "index_notifications_on_viewed"

  create_table "post_bans", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "post_bans", ["post_id", "user_id"], :name => "index_post_bans_on_post_id_and_user_id", :unique => true
  add_index "post_bans", ["post_id"], :name => "index_post_bans_on_post_id"

  create_table "post_reports", :force => true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.string   "category"
    t.string   "reason"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "post_reports", ["created_at"], :name => "index_post_reports_on_created_at"
  add_index "post_reports", ["post_id"], :name => "index_post_reports_on_post_id"
  add_index "post_reports", ["user_id"], :name => "index_post_reports_on_user_id"

  create_table "posts", :force => true do |t|
    t.text     "content"
    t.string   "file_url"
    t.integer  "user_id"
    t.integer  "ban_count",      :default => 0
    t.integer  "like_count",     :default => 0
    t.integer  "rating"
    t.float    "longitude",      :default => 0.0
    t.float    "latitude",       :default => 0.0
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "privacy_option", :default => "friends"
    t.integer  "landmark_id"
    t.string   "subject"
    t.string   "thumbnail_url"
    t.datetime "release"
    t.string   "topic"
    t.datetime "posted_at"
  end

  add_index "posts", ["ban_count"], :name => "index_posts_on_ban_count"
  add_index "posts", ["created_at"], :name => "index_posts_on_created_at"
  add_index "posts", ["landmark_id"], :name => "index_posts_on_landmark_id"
  add_index "posts", ["privacy_option"], :name => "index_posts_on_privacy_option"
  add_index "posts", ["release"], :name => "index_posts_on_release"
  add_index "posts", ["user_id", "created_at"], :name => "index_posts_on_user_id_and_created_at"

  create_table "public_post_locations", :force => true do |t|
    t.integer  "post_id"
    t.float    "longitude"
    t.float    "latitude"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "talks", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "topics"
    t.integer  "event_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "address"
    t.integer  "postal_code"
  end

  add_index "talks", ["event_id"], :name => "index_talks_on_event_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",             :default => false
    t.string   "avatar_url"
    t.boolean  "public",            :default => false
    t.integer  "confirmation_code"
    t.string   "phone_number"
    t.datetime "birthdate"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["public"], :name => "index_users_on_public"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
