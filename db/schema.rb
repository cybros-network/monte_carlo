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

ActiveRecord::Schema[7.1].define(version: 2023_08_01_001533) do
  create_table "glossaries", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_glossaries_on_user_id"
  end

  create_table "identities", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider", null: false
    t.string "extern_uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "prompt_elements", force: :cascade do |t|
    t.integer "prompting_plan_id", null: false
    t.boolean "negative", default: false, null: false
    t.integer "order"
    t.string "text"
    t.integer "glossary_id"
    t.integer "frequency"
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["glossary_id"], name: "index_prompt_elements_on_glossary_id"
    t.index ["prompting_plan_id"], name: "index_prompt_elements_on_prompting_plan_id"
  end

  create_table "prompting_plans", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.string "sd_model_name", null: false
    t.string "sampler_name", null: false
    t.integer "width", null: false
    t.integer "height", null: false
    t.integer "fixed_seed"
    t.integer "min_steps", null: false
    t.integer "max_steps", null: false
    t.float "min_cfg_scale", null: false
    t.float "max_cfg_scale", null: false
    t.boolean "hires_fix", null: false
    t.string "hires_fix_upscaler_name"
    t.float "hires_fix_upscale"
    t.integer "hires_fix_min_steps"
    t.integer "hires_fix_max_steps"
    t.float "hires_fix_min_denoising"
    t.float "hires_fix_max_denoising"
    t.integer "positive_prompt_elements_count", default: 0, null: false
    t.integer "negative_prompt_elements_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_prompting_plans_on_user_id"
  end

  create_table "prompting_tasks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "prompting_plan_id"
    t.text "positive_prompt", null: false
    t.text "negative_prompt"
    t.string "sd_model_name", null: false
    t.string "sampler_name", null: false
    t.integer "width", null: false
    t.integer "height", null: false
    t.integer "seed", null: false
    t.integer "steps", null: false
    t.float "cfg_scale", null: false
    t.boolean "hires_fix", null: false
    t.string "hires_fix_upscaler_name"
    t.float "hires_fix_upscale"
    t.integer "hires_fix_steps"
    t.float "hires_fix_denoising"
    t.string "status", null: false
    t.integer "unique_track_id"
    t.text "frozen_prompt"
    t.text "transaction_id"
    t.string "result"
    t.text "raw_output"
    t.text "generated_image_url"
    t.datetime "submitting_at"
    t.datetime "submitted_at"
    t.datetime "processing_at"
    t.datetime "processed_at"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompting_plan_id"], name: "index_prompting_tasks_on_prompting_plan_id"
    t.index ["user_id"], name: "index_prompting_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "vocabularies", force: :cascade do |t|
    t.string "text", null: false
    t.integer "glossary_id", null: false
    t.index ["glossary_id"], name: "index_vocabularies_on_glossary_id"
  end

  add_foreign_key "glossaries", "users"
  add_foreign_key "identities", "users"
  add_foreign_key "prompt_elements", "glossaries"
  add_foreign_key "prompt_elements", "prompting_plans"
  add_foreign_key "prompting_plans", "users"
  add_foreign_key "prompting_tasks", "prompting_plans"
  add_foreign_key "prompting_tasks", "users"
  add_foreign_key "vocabularies", "glossaries"
end
