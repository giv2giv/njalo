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

ActiveRecord::Schema.define(version: 20150302205142) do

  create_table "authorizations", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.string   "token"
    t.string   "secret"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns", force: true do |t|
    t.string   "name",                                                 null: false
    t.integer  "user_id"
    t.string   "tagline"
    t.text     "description"
    t.integer  "minimum_donation_amount",     limit: 2, default: 5
    t.integer  "maximum_donation_amount",     limit: 2, default: 1000
    t.integer  "minimum_passthru_percentage", limit: 1, default: 0
    t.integer  "maximum_passthru_percentage", limit: 1, default: 0
    t.integer  "initial_donation_amount",     limit: 2, default: 25
    t.integer  "initial_passthru_percent",    limit: 1, default: 50
    t.boolean  "initial_donor_assumes_fees",            default: true
    t.string   "widget_callback_url"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns_charities", id: false, force: true do |t|
    t.integer  "campaign_id", null: false
    t.integer  "charity_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaigns_charities", ["campaign_id", "charity_id"], name: "campaigns_charities_compound", unique: true
  add_index "campaigns_charities", ["campaign_id"], name: "index_campaigns_charities_on_campaign_id"
  add_index "campaigns_charities", ["charity_id"], name: "index_campaigns_charities_on_charity_id"

  create_table "campaigns_donors", id: false, force: true do |t|
    t.integer  "campaign_id", null: false
    t.integer  "donor_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaigns_donors", ["campaign_id", "donor_id"], name: "champaigns_donors_compound", unique: true
  add_index "campaigns_donors", ["campaign_id"], name: "index_campaigns_donors_on_campaign_id"
  add_index "campaigns_donors", ["donor_id"], name: "index_campaigns_donors_on_donor_id"

  create_table "charities", force: true do |t|
    t.string   "name"
    t.string   "display_name"
    t.string   "ein",                                   null: false
    t.string   "care_of"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "group_code"
    t.string   "affiliation_code"
    t.string   "ntee_code"
    t.date     "ruling_date"
    t.string   "classification_code"
    t.string   "deductibility_code"
    t.string   "foundation_code"
    t.string   "subsection_code"
    t.string   "activity_code"
    t.string   "organization_code"
    t.string   "status_code"
    t.string   "asset_code"
    t.string   "income_code"
    t.string   "filing_requirement_code"
    t.string   "pf_filing_requirement_code"
    t.string   "tax_period"
    t.string   "accounting_period"
    t.integer  "asset_amount",               limit: 8
    t.integer  "income_amount",              limit: 8
    t.integer  "revenue_amount",             limit: 8
    t.string   "description"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.float    "latitude",                   limit: 24
    t.float    "longitude",                  limit: 24
    t.string   "slug"
  end

  add_index "charities", ["ein"], name: "index_charities_on_ein", unique: true
  add_index "charities", ["slug"], name: "index_charities_on_slug", unique: true

  create_table "charities_tags", force: true do |t|
    t.integer "charity_id", null: false
    t.integer "tag_id",     null: false
  end

  add_index "charities_tags", ["charity_id", "tag_id"], name: "index_charities_tags_on_charity_id_and_tag_id", unique: true

  create_table "donations", force: true do |t|
    t.integer  "donor_id",                                                              null: false
    t.integer  "campaign_id",                                                           null: false
    t.decimal  "gross_amount",             precision: 30, scale: 2,                     null: false
    t.decimal  "shares_added",                                                          null: false
    t.decimal  "transaction_fee",          precision: 30, scale: 2,                     null: false
    t.decimal  "net_amount",               precision: 30, scale: 2,                     null: false
    t.string   "processor_transaction_id",                                              null: false
    t.string   "status",                                            default: "pending", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "donors", force: true do |t|
    t.string   "name"
    t.string   "stripe_customer_id"
    t.string   "string"
    t.string   "address"
    t.string   "city"
    t.string   "state",              limit: 2
    t.string   "zip",                limit: 10
    t.string   "phone_number",       limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "etrade_tokens", force: true do |t|
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shares", force: true do |t|
    t.decimal  "share_total_beginning",       precision: 30, scale: 20
    t.decimal  "shares_added_by_donation",    precision: 30, scale: 20
    t.decimal  "shares_subtracted_by_grants", precision: 30, scale: 20
    t.decimal  "share_total_end",             precision: 30, scale: 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "stripe_balance",              precision: 10, scale: 2
    t.decimal  "etrade_balance",              precision: 10, scale: 2
    t.decimal  "donation_price",              precision: 10, scale: 2
    t.decimal  "grant_price",                 precision: 10, scale: 2
  end

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id",                                            null: false
    t.integer  "payment_account_id",                                 null: false
    t.integer  "charity_id",                                         null: false
    t.string   "processor_subscription_id"
    t.text     "type_subscription"
    t.decimal  "gross_amount",              precision: 30, scale: 2, null: false
    t.datetime "canceled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "name",       limit: 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["id"], name: "index_tags_on_id"

  create_table "transit_funds", force: true do |t|
    t.string   "transaction_id",                                          null: false
    t.string   "source",                                                  null: false
    t.string   "destination",                                             null: false
    t.decimal  "amount",         precision: 30, scale: 2,                 null: false
    t.boolean  "cleared",                                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "role_id"
    t.string   "role_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["role_id", "role_type"], name: "index_users_on_role_id_and_role_type"

end
