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

ActiveRecord::Schema.define(version: 20130815194016) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "builds", force: true do |t|
    t.integer  "number",                       null: false
    t.integer  "project_id",                   null: false
    t.string   "sha",                          null: false
    t.string   "branch",                       null: false
    t.integer  "pull_request_id"
    t.string   "author"
    t.string   "message"
    t.integer  "status",          default: 0,  null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "jobs_count",      default: 0,  null: false
    t.string   "matrix",          default: [],              array: true
    t.string   "author_email"
  end

  add_index "builds", ["project_id", "number"], name: "index_builds_on_project_id_and_number", unique: true, using: :btree

  create_table "github_repos", force: true do |t|
    t.integer  "user_id",                            null: false
    t.string   "organization_login"
    t.string   "full_name",                          null: false
    t.boolean  "is_private",                         null: false
    t.string   "ssh_url",                            null: false
    t.string   "html_url",                           null: false
    t.boolean  "subscribed",         default: false, null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "github_repos", ["user_id", "full_name"], name: "index_github_repos_on_user_id_and_full_name", unique: true, using: :btree

  create_table "jobs", force: true do |t|
    t.integer  "build_id",    null: false
    t.integer  "number",      null: false
    t.integer  "status",      null: false
    t.hstore   "matrix"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jobs", ["build_id", "number"], name: "index_jobs_on_build_id_and_number", unique: true, using: :btree

  create_table "projects", force: true do |t|
    t.string   "name",        null: false
    t.string   "http_url",    null: false
    t.string   "clone_url",   null: false
    t.text     "description"
    t.string   "provider"
    t.text     "deploy_key",  null: false
    t.string   "token",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["name"], name: "index_projects_on_name", unique: true, using: :btree

  create_table "user_identities", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "provider",   null: false
    t.string   "token",      null: false
    t.string   "uid",        null: false
    t.string   "login",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_identities", ["user_id", "provider"], name: "index_user_identities_on_user_id_and_provider", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",      null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
