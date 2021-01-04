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

ActiveRecord::Schema.define(version: 2019_06_20_110417) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "activity_event_type_pricing_associations", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "event_type_pricing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_activity_event_type_pricing_associations_on_event_id"
    t.index ["event_type_pricing_id"], name: "index_activity_pricing_associations_on_event_type_pricing_id"
  end

  create_table "address_proof_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "first_line", limit: 255
    t.string "second_line", limit: 255
    t.integer "city_id"
    t.string "district", limit: 255
    t.integer "state_id"
    t.string "postal_code", limit: 255
    t.integer "country_id"
    t.string "address_type", limit: 255
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "addressable_id"
    t.string "addressable_type", limit: 255
    t.decimal "lat", precision: 16, scale: 8
    t.decimal "lng", precision: 16, scale: 8
    t.string "other_state", limit: 255
    t.string "other_city", limit: 255
    t.datetime "deleted_at"
    t.decimal "latitude"
    t.decimal "longitude"
    t.index ["addressable_id", "addressable_type"], name: "index_addresses_on_addressable_id_and_addressable_type"
    t.index ["city_id"], name: "index_addresses_on_city_id"
    t.index ["country_id"], name: "index_addresses_on_country_id"
    t.index ["deleted_at"], name: "index_addresses_on_deleted_at"
    t.index ["latitude", "longitude"], name: "index_addresses_on_latitude_and_longitude"
    t.index ["state_id"], name: "index_addresses_on_state_id"
  end

  create_table "advance_profiles", id: :serial, force: :cascade do |t|
    t.string "faith", limit: 255
    t.boolean "any_legal_proceeding"
    t.boolean "attended_any_shivir"
    t.string "photograph_url", limit: 255
    t.string "photograph_path", limit: 255
    t.string "photo_id_proof_type", limit: 255
    t.string "photo_id_proof_number", limit: 255
    t.string "photo_id_proof_url", limit: 255
    t.string "photo_id_proof_path", limit: 255
    t.string "address_proof_type", limit: 255
    t.string "address_proof_url", limit: 255
    t.string "address_proof_path", limit: 255
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "address_proof_type_id"
    t.integer "photo_id_proof_type_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_advance_profiles_on_deleted_at"
    t.index ["sadhak_profile_id"], name: "index_advance_profiles_on_sadhak_profile_id"
  end

  create_table "advisory_counsils", force: :cascade do |t|
    t.date "club_joining_date"
    t.string "guest_email"
    t.integer "sy_club_sadhak_profile_association_id"
    t.datetime "deleted_at"
    t.bigint "sadhak_profile_id"
    t.bigint "sy_club_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_advisory_counsils_on_deleted_at"
    t.index ["sadhak_profile_id"], name: "index_advisory_counsils_on_sadhak_profile_id"
    t.index ["sy_club_id"], name: "index_advisory_counsils_on_sy_club_id"
  end

  create_table "ahoy_events_new", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "visit_id"
    t.integer "user_id"
    t.string "name", limit: 255
    t.json "properties"
    t.datetime "time"
  end

  create_table "aspect_feedbacks", id: :serial, force: :cascade do |t|
    t.integer "aspect_type"
    t.integer "rating_before"
    t.string "descripton_before", limit: 255
    t.integer "rating_after"
    t.string "description_after", limit: 255
    t.integer "aspects_of_life_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_aspect_feedbacks_on_deleted_at"
  end

  create_table "aspects_of_lives", id: :serial, force: :cascade do |t|
    t.string "benefits_to_family", limit: 255
    t.string "other_areas_of_improvement", limit: 255
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_aspects_of_lives_on_deleted_at"
  end

  create_table "asset_group_mappings", id: :serial, force: :cascade do |t|
    t.integer "digital_asset_id", null: false
    t.integer "user_group_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["digital_asset_id", "user_group_id"], name: "index_a_g_m_on_digital_asset_id_and_user_group_id", unique: true
  end

  create_table "asset_tag_mappings", id: :serial, force: :cascade do |t|
    t.integer "digital_asset_id", null: false
    t.integer "asset_tag_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["asset_tag_id"], name: "index_asset_tag_mappings_on_asset_tag_id"
    t.index ["digital_asset_id", "asset_tag_id"], name: "index_asset_tag_mappings_on_digital_asset_id_and_asset_tag_id", unique: true
    t.index ["digital_asset_id"], name: "index_asset_tag_mappings_on_digital_asset_id"
  end

  create_table "asset_tags", id: :serial, force: :cascade do |t|
    t.string "tag", limit: 255
    t.integer "tag_priority"
    t.integer "digital_asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "tag_collection_id"
    t.string "thumbnail_url", limit: 255
    t.string "thumbnail_path", limit: 255
    t.index ["digital_asset_id"], name: "index_asset_tags_on_digital_asset_id"
    t.index ["tag_collection_id"], name: "index_asset_tags_on_tag_collection_id"
  end

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "file_type", limit: 255
    t.string "file_size", limit: 255
    t.string "s3_url", limit: 255
    t.string "s3_path", limit: 255
    t.string "s3_bucket", limit: 255
    t.boolean "is_secure"
    t.integer "attachable_id"
    t.string "attachable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "content"
    t.index ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type"
    t.index ["deleted_at"], name: "index_attachments_on_deleted_at"
  end

  create_table "authentication_tokens", id: :serial, force: :cascade do |t|
    t.string "body"
    t.integer "user_id"
    t.datetime "last_used_at"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_authentication_tokens_on_deleted_at"
    t.index ["user_id"], name: "index_authentication_tokens_on_user_id"
  end

  create_table "bhandara_details", id: :serial, force: :cascade do |t|
    t.decimal "budget", precision: 10, scale: 2
    t.integer "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bhandara_items", id: :serial, force: :cascade do |t|
    t.integer "day"
    t.string "item_name", limit: 255
    t.integer "bhandara_detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["bhandara_detail_id"], name: "index_bhandara_items_on_bhandara_detail_id"
  end

  create_table "cannonical_event_digital_asset_associations", id: :serial, force: :cascade do |t|
    t.integer "cannonical_event_id"
    t.integer "digital_asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cannonical_events", id: :serial, force: :cascade do |t|
    t.string "event_name", limit: 255
    t.string "event_meta_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ccavenue_configs", id: :serial, force: :cascade do |t|
    t.string "alias_name", limit: 255
    t.string "working_key", limit: 255
    t.string "merchant_id", limit: 255
    t.string "access_code", limit: 255
    t.integer "payment_gateway_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "country_id"
    t.float "tax_amount"
    t.index ["payment_gateway_id"], name: "index_ccavenue_configs_on_payment_gateway_id"
  end

  create_table "chrome_logs", force: :cascade do |t|
    t.integer "user_id"
    t.integer "asset_id"
    t.string "status"
    t.datetime "date_time"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ip_address"
  end

  create_table "collection_event_type_associations", force: :cascade do |t|
    t.string "sadhak_profile_ids"
    t.bigint "collection_id"
    t.bigint "event_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_collection_event_type_associations_on_collection_id"
    t.index ["event_type_id"], name: "index_collection_event_type_associations_on_event_type_id"
  end

  create_table "collections", id: :serial, force: :cascade do |t|
    t.string "collection_thumbnail_url", limit: 255
    t.date "collection_expiry_date"
    t.integer "digital_asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "collection_name", limit: 255
    t.text "collection_description"
    t.integer "source_asset_id"
    t.datetime "deleted_at"
    t.integer "collection_type", default: 0
    t.text "announcement_text"
    t.index ["deleted_at"], name: "index_collections_on_deleted_at"
    t.index ["source_asset_id"], name: "index_collections_on_source_asset_id"
  end

  create_table "comfy_blog_posts", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "title", null: false
    t.string "slug", null: false
    t.integer "layout_id"
    t.text "content_cache"
    t.integer "year", null: false
    t.integer "month", limit: 2, null: false
    t.boolean "is_published", default: true, null: false
    t.datetime "published_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_comfy_blog_posts_on_created_at"
    t.index ["site_id", "is_published"], name: "index_comfy_blog_posts_on_site_id_and_is_published"
    t.index ["year", "month", "slug"], name: "index_comfy_blog_posts_on_year_and_month_and_slug"
  end

  create_table "comfy_cms_categories", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "label", null: false
    t.string "categorized_type", null: false
    t.index ["site_id", "categorized_type", "label"], name: "index_cms_categories_on_site_id_and_cat_type_and_label", unique: true
  end

  create_table "comfy_cms_categorizations", force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "categorized_type", null: false
    t.integer "categorized_id", null: false
    t.index ["category_id", "categorized_type", "categorized_id"], name: "index_cms_categorizations_on_cat_id_and_catd_type_and_catd_id", unique: true
  end

  create_table "comfy_cms_files", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "label", default: "", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id", "position"], name: "index_comfy_cms_files_on_site_id_and_position"
  end

  create_table "comfy_cms_fragments", force: :cascade do |t|
    t.string "record_type"
    t.bigint "record_id"
    t.string "identifier", null: false
    t.string "tag", default: "text", null: false
    t.text "content"
    t.boolean "boolean", default: false, null: false
    t.datetime "datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["boolean"], name: "index_comfy_cms_fragments_on_boolean"
    t.index ["datetime"], name: "index_comfy_cms_fragments_on_datetime"
    t.index ["identifier"], name: "index_comfy_cms_fragments_on_identifier"
    t.index ["record_type", "record_id"], name: "index_comfy_cms_fragments_on_record_type_and_record_id"
  end

  create_table "comfy_cms_layouts", force: :cascade do |t|
    t.integer "site_id", null: false
    t.integer "parent_id"
    t.string "app_layout"
    t.string "label", null: false
    t.string "identifier", null: false
    t.text "content"
    t.text "css"
    t.text "js"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id", "position"], name: "index_comfy_cms_layouts_on_parent_id_and_position"
    t.index ["site_id", "identifier"], name: "index_comfy_cms_layouts_on_site_id_and_identifier", unique: true
  end

  create_table "comfy_cms_pages", force: :cascade do |t|
    t.integer "site_id", null: false
    t.integer "layout_id"
    t.integer "parent_id"
    t.integer "target_page_id"
    t.string "label", null: false
    t.string "slug"
    t.string "full_path", null: false
    t.text "content_cache"
    t.integer "position", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.boolean "is_published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_published"], name: "index_comfy_cms_pages_on_is_published"
    t.index ["parent_id", "position"], name: "index_comfy_cms_pages_on_parent_id_and_position"
    t.index ["site_id", "full_path"], name: "index_comfy_cms_pages_on_site_id_and_full_path"
  end

  create_table "comfy_cms_revisions", force: :cascade do |t|
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.index ["record_type", "record_id", "created_at"], name: "index_cms_revisions_on_rtype_and_rid_and_created_at"
  end

  create_table "comfy_cms_sites", force: :cascade do |t|
    t.string "label", null: false
    t.string "identifier", null: false
    t.string "hostname", null: false
    t.string "path"
    t.string "locale", default: "en", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hostname"], name: "index_comfy_cms_sites_on_hostname"
  end

  create_table "comfy_cms_snippets", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "label", null: false
    t.string "identifier", null: false
    t.text "content"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id", "identifier"], name: "index_comfy_cms_snippets_on_site_id_and_identifier", unique: true
    t.index ["site_id", "position"], name: "index_comfy_cms_snippets_on_site_id_and_position"
  end

  create_table "comfy_cms_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.integer "page_id", null: false
    t.integer "layout_id"
    t.string "label", null: false
    t.text "content_cache"
    t.boolean "is_published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_published"], name: "index_comfy_cms_translations_on_is_published"
    t.index ["locale"], name: "index_comfy_cms_translations_on_locale"
    t.index ["page_id"], name: "index_comfy_cms_translations_on_page_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "comment"
    t.integer "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "create_forum_requests", force: :cascade do |t|
    t.string "name"
    t.string "no_of_people"
    t.text "about_forum"
    t.text "description"
    t.string "motive"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cryptos", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dashboard_widget_configs", id: :serial, force: :cascade do |t|
    t.boolean "is_visible", default: true
    t.string "name", limit: 255
    t.integer "widget"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "db_cities", id: :serial, force: :cascade do |t|
    t.integer "country_id"
    t.integer "state_id"
    t.string "name", limit: 255
    t.decimal "lat", precision: 16, scale: 8
    t.decimal "lng", precision: 16, scale: 8
    t.string "timezone", limit: 255
    t.integer "dma_id"
    t.string "code", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "db_countries", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "FIPS104", limit: 255
    t.string "ISO2", limit: 255
    t.string "ISO3", limit: 255
    t.string "ISON", limit: 255
    t.string "internet", limit: 255
    t.string "capital", limit: 255
    t.string "map_reference", limit: 255
    t.string "nationality_singular", limit: 255
    t.string "nationality_plural", limit: 255
    t.string "currency", limit: 255
    t.string "currency_code", limit: 255
    t.integer "population"
    t.string "title", limit: 255
    t.text "comment"
    t.string "telephone_prefix", limit: 255
  end

  create_table "db_states", id: :serial, force: :cascade do |t|
    t.integer "country_id"
    t.string "name", limit: 255
    t.string "code", limit: 255
    t.string "adm1_code", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_job_progresses", id: :serial, force: :cascade do |t|
    t.text "progress_stage", default: "Queued"
    t.float "progress_current", default: 0.0
    t.float "progress_max", default: 0.0
    t.text "result"
    t.text "last_error"
    t.datetime "deleted_at"
    t.integer "status", default: 0
    t.integer "user_id"
    t.integer "delayed_job_progressable_id"
    t.string "delayed_job_progressable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_delayed_job_progresses_on_deleted_at"
    t.index ["user_id"], name: "index_delayed_job_progresses_on_user_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.string "queue", limit: 255
    t.integer "delayed_reference_id"
    t.string "delayed_reference_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["delayed_reference_id", "delayed_reference_type"], name: "delayed_jobs_reference_type_and_id"
    t.index ["delayed_reference_id"], name: "delayed_jobs_delayed_reference_id"
    t.index ["delayed_reference_type"], name: "delayed_jobs_delayed_reference_type"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    t.index ["queue"], name: "delayed_jobs_queue"
  end

  create_table "digital_asset_secrets", id: :serial, force: :cascade do |t|
    t.string "video_id", limit: 255
    t.text "embed_code"
    t.text "asset_dl_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "asset_hls_url", limit: 255
    t.string "asset_sd_url", limit: 255
    t.string "asset_mobile_url", limit: 255
    t.integer "digital_asset_id"
    t.string "asset_file_name", limit: 255
    t.string "asset_url", limit: 255
    t.bigint "asset_file_size"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_digital_asset_secrets_on_deleted_at"
    t.index ["digital_asset_id"], name: "index_digital_asset_secrets_on_digital_asset_id"
  end

  create_table "digital_assets", id: :serial, force: :cascade do |t|
    t.string "asset_name", limit: 255
    t.text "asset_description"
    t.string "asset_type", limit: 255
    t.decimal "price"
    t.string "allowable_promo_code", limit: 255
    t.string "asset_list_thumbnail_url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "asset_content_type", limit: 255
    t.bigint "asset_file_size"
    t.datetime "asset_updated_at"
    t.string "thumbnail_image_file_name", limit: 255
    t.string "thumbnail_image_content_type", limit: 255
    t.integer "thumbnail_image_file_size"
    t.datetime "thumbnail_image_updated_at"
    t.integer "collection_id"
    t.boolean "is_collection", default: false
    t.integer "collection_priority"
    t.string "video_id", limit: 255
    t.boolean "is_owned"
    t.string "asset_large_thumbnail_url", limit: 255
    t.string "currency", limit: 255, default: "INR"
    t.integer "digital_asset_secret_id"
    t.string "author", limit: 255
    t.boolean "is_for_sale_on_store", default: true
    t.string "language", limit: 255
    t.integer "available_for", default: 0
    t.date "published_on"
    t.date "expires_at"
    t.datetime "deleted_at"
    t.integer "asset_order", default: 0
    t.index ["asset_name"], name: "index_digital_assets_on_asset_name"
    t.index ["author"], name: "index_digital_assets_on_author"
    t.index ["collection_id"], name: "index_digital_assets_on_collection_id"
    t.index ["deleted_at"], name: "index_digital_assets_on_deleted_at"
    t.index ["digital_asset_secret_id"], name: "index_digital_assets_on_digital_asset_secret_id"
  end

  create_table "discount_plans", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "discount_type"
    t.decimal "discount_amount", precision: 10, scale: 2
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_delete", default: false
  end

  create_table "doctors_profiles", id: :serial, force: :cascade do |t|
    t.string "medical_school", limit: 255
    t.string "education_country_id", limit: 255
    t.integer "year_of_graduation"
    t.string "area_of_speciality", limit: 255
    t.string "sub_speciality", limit: 255
    t.integer "license_status"
    t.integer "license_state_id"
    t.integer "license_country_id"
    t.string "primary_work_setting", limit: 255
    t.string "practice_place", limit: 255
    t.integer "practice_state_id"
    t.integer "practice_country_id"
    t.integer "practice_years"
    t.boolean "clinical_research"
    t.string "hospital_affiliations", limit: 255
    t.string "professional_publications", limit: 255
    t.string "honors_and_awards", limit: 255
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_doctors_profiles_on_deleted_at"
  end

  create_table "ds_asset_tag_collections", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "ds_asset_tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ds_asset_tag_id"], name: "index_ds_asset_tag_collections_on_ds_asset_tag_id"
  end

  create_table "ds_asset_tags", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ds_inventory_requests", id: :serial, force: :cascade do |t|
    t.integer "quantity"
    t.integer "ds_product_id"
    t.integer "ds_product_inventory_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "ds_asset_tag_id"
    t.index ["ds_product_id"], name: "index_ds_inventory_requests_on_ds_product_id"
    t.index ["ds_product_inventory_request_id"], name: "index_ds_inventory_requests_on_ds_product_inventory_request_id"
  end

  create_table "ds_product_asset_tag_associations", id: :serial, force: :cascade do |t|
    t.integer "ds_product_id"
    t.integer "ds_asset_tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ds_asset_tag_id"], name: "index_ds_product_asset_tag_associations_on_ds_asset_tag_id"
    t.index ["ds_product_id"], name: "index_ds_product_asset_tag_associations_on_ds_product_id"
  end

  create_table "ds_product_details", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.boolean "availability", default: false
    t.boolean "boolean", default: false
    t.string "video_url", limit: 255
    t.string "ds_product_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ds_product_inventories", id: :serial, force: :cascade do |t|
    t.integer "ds_product_id"
    t.integer "ds_shop_id"
    t.string "quantity", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ds_product_id"], name: "index_ds_product_inventories_on_ds_product_id"
    t.index ["ds_shop_id"], name: "index_ds_product_inventories_on_ds_shop_id"
  end

  create_table "ds_product_inventory_requests", id: :serial, force: :cascade do |t|
    t.integer "ds_shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "status"
    t.index ["ds_shop_id"], name: "index_ds_product_inventory_requests_on_ds_shop_id"
  end

  create_table "ds_products", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "ds_asset_tag_id"
    t.index ["ds_asset_tag_id"], name: "index_ds_products_on_ds_asset_tag_id"
  end

  create_table "ds_shops", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.integer "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_ds_shops_on_event_id"
  end

  create_table "email_subscriptions", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_awareness_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "code", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_awarenesses", id: :serial, force: :cascade do |t|
    t.integer "event_awareness_type_id"
    t.integer "event_id"
    t.decimal "budget", precision: 10, scale: 2
    t.string "event_awareness_type_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_awareness_type_id"], name: "index_event_awarenesses_on_event_awareness_type_id"
    t.index ["event_id"], name: "index_event_awarenesses_on_event_id"
  end

  create_table "event_cancellation_plan_items", id: :serial, force: :cascade do |t|
    t.integer "event_cancellation_plan_id"
    t.integer "days_before"
    t.decimal "amount", precision: 10, scale: 2, default: "0.0"
    t.integer "amount_type"
    t.boolean "is_deleted", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_cancellation_plan_id"], name: "index_event_cancellation_plan_items_on_cancellation_plan_id"
  end

  create_table "event_cancellation_plans", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.boolean "is_deleted", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_cost_estimations", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.decimal "budget", precision: 10, scale: 2
    t.integer "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_event_cost_estimations_on_event_id"
  end

  create_table "event_digital_asset_associations", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "digital_asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["digital_asset_id"], name: "index_event_digital_asset_associations_on_digital_asset_id"
    t.index ["event_id"], name: "index_event_digital_asset_associations_on_event_id"
  end

  create_table "event_discount_plan_associations", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "discount_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["discount_plan_id"], name: "index_event_discount_plan_associations_on_discount_plan_id"
    t.index ["event_id"], name: "index_event_discount_plan_associations_on_event_id"
  end

  create_table "event_gift_logs", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "status"
    t.text "message"
    t.index ["event_id"], name: "index_event_gift_logs_on_event_id"
  end

  create_table "event_order_line_item_versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.text "object"
    t.string "ip", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "whodunnit", limit: 255
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_event_order_line_item_versions_on_item_type_and_item_id"
  end

  create_table "event_order_line_items", id: :serial, force: :cascade do |t|
    t.integer "event_order_id"
    t.integer "sadhak_profile_id"
    t.integer "seating_category_id"
    t.decimal "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_seating_category_association_id"
    t.integer "registration_number"
    t.integer "status"
    t.string "transferred_ref_number", limit: 255
    t.boolean "is_extra_seat", default: false
    t.integer "event_type_pricing_id"
    t.boolean "is_deleted", default: false
    t.decimal "discount", precision: 10, scale: 2, default: "0.0"
    t.boolean "available_for_seva", default: false
    t.text "tax_types"
    t.text "tax_details"
    t.text "total_tax_detail"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_event_order_line_items_on_deleted_at"
    t.index ["event_type_pricing_id"], name: "index_event_order_line_items_on_event_type_pricing_id"
  end

  create_table "event_order_versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.text "object"
    t.string "ip", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "whodunnit", limit: 255
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_event_order_versions_on_item_type_and_item_id"
  end

  create_table "event_orders", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.integer "registration_center_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "status"
    t.decimal "total_amount"
    t.text "final_line_items"
    t.text "gateway_redirect_url"
    t.string "guest_email", limit: 255
    t.string "transaction_id", limit: 255
    t.string "payment_method", limit: 255
    t.boolean "is_4_eye_verified", default: false
    t.boolean "is_guest_user", default: false
    t.integer "registration_center_id"
    t.string "reg_ref_number", limit: 255, null: false
    t.boolean "is_club_order", default: false
    t.integer "sy_club_id"
    t.decimal "total_discount", precision: 10, scale: 2, default: "0.0"
    t.text "tax_details"
    t.text "order_tax_detail"
    t.text "total_tax_details"
    t.boolean "is_deleted", default: false
    t.string "slug"
    t.index ["event_id"], name: "index_event_orders_on_event_id"
    t.index ["reg_ref_number"], name: "index_event_orders_on_reg_ref_number", unique: true
    t.index ["slug"], name: "index_event_orders_on_slug", unique: true
  end

  create_table "event_payment_gateway_associations", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "payment_gateway_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "payment_start_date"
    t.date "payment_end_date"
    t.index ["event_id"], name: "index_event_payment_gateway_associations_on_event_id"
    t.index ["payment_gateway_id"], name: "index_event_payment_gateway_associations_on_payment_gateway_id"
  end

  create_table "event_prerequisites", id: :serial, force: :cascade do |t|
    t.integer "cannonical_event_id"
    t.integer "prerequisite_cannonical_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_prerequisites_event_types", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "event_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_event_prerequisites_event_types_on_event_id"
    t.index ["event_type_id"], name: "index_event_prerequisites_event_types_on_event_type_id"
  end

  create_table "event_references", id: :serial, force: :cascade do |t|
    t.integer "sadhak_profile_id"
    t.integer "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_event_references_on_deleted_at"
    t.index ["event_id"], name: "index_event_references_on_event_id"
    t.index ["sadhak_profile_id"], name: "index_event_references_on_sadhak_profile_id"
  end

  create_table "event_registration_center_associations", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "registration_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_cash_payment_allowed", default: false
  end

  create_table "event_registration_versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.text "object"
    t.string "ip", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "whodunnit", limit: 255
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_event_registration_versions_on_item_type_and_item_id"
  end

  create_table "event_registrations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.text "special_considerations"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_seating_category_association_id"
    t.integer "sadhak_profile_id"
    t.integer "event_order_id"
    t.integer "status"
    t.boolean "is_extra_seat", default: false
    t.integer "event_order_line_item_id"
    t.integer "event_type_pricing_id"
    t.boolean "has_attended", default: true
    t.string "invoice_number", limit: 255
    t.integer "serial_number"
    t.integer "sy_event_company_id"
    t.integer "expires_at"
    t.integer "renewed_from"
    t.boolean "is_deleted", default: false
    t.datetime "deleted_at"
    t.string "voucher_number"
    t.index ["deleted_at"], name: "index_event_registrations_on_deleted_at"
    t.index ["event_type_pricing_id"], name: "index_event_registrations_on_event_type_pricing_id"
    t.index ["sy_event_company_id"], name: "index_event_registrations_on_sy_event_company_id"
  end

  create_table "event_sadhak_questionnaires", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "sadhak_profile_id"
    t.text "data"
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_sadhak_questionnaires_on_event_id"
    t.index ["sadhak_profile_id"], name: "index_event_sadhak_questionnaires_on_sadhak_profile_id"
  end

  create_table "event_seating_category_association_versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.text "object"
    t.string "ip", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "whodunnit", limit: 255
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_event_category_ass_versions_on_item_type_and_item_id"
  end

  create_table "event_seating_category_associations", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "seating_category_id"
    t.decimal "price", precision: 10, scale: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "seating_capacity"
    t.float "cancellation_charge"
    t.boolean "is_deleted", default: false
  end

  create_table "event_sponsors", id: :serial, force: :cascade do |t|
    t.integer "sadhak_profile_id"
    t.integer "event_id"
    t.text "remarks"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_event_sponsors_on_deleted_at"
    t.index ["event_id"], name: "index_event_sponsors_on_event_id"
    t.index ["sadhak_profile_id"], name: "index_event_sponsors_on_sadhak_profile_id"
  end

  create_table "event_tax_type_associations", id: :serial, force: :cascade do |t|
    t.float "percent"
    t.integer "sequence"
    t.integer "event_id"
    t.integer "tax_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false
    t.index ["event_id"], name: "index_event_tax_type_associations_on_event_id"
    t.index ["tax_type_id"], name: "index_event_tax_type_associations_on_tax_type_id"
  end

  create_table "event_team_details", id: :serial, force: :cascade do |t|
    t.integer "team_type"
    t.integer "role"
    t.string "first_name", limit: 255
    t.string "syid", limit: 255
    t.integer "event_id"
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_event_team_details_on_event_id"
    t.index ["sadhak_profile_id"], name: "index_event_team_details_on_sadhak_profile_id"
  end

  create_table "event_type_digital_asset_associations", id: :serial, force: :cascade do |t|
    t.integer "event_type_id"
    t.integer "digital_asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["digital_asset_id"], name: "index_event_type_digital_asset_associations_on_digital_asset_id"
    t.index ["event_type_id"], name: "index_event_type_digital_asset_associations_on_event_type_id"
  end

  create_table "event_type_pricings", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.decimal "price", precision: 10, scale: 2
    t.string "tier_type", limit: 255
    t.integer "event_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 255
    t.integer "event_meta_type"
    t.boolean "is_club_activity", default: false
    t.string "feedback_form", limit: 255
    t.integer "reference_event_id"
  end

  create_table "event_versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.text "object"
    t.string "ip", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "whodunnit", limit: 255
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_event_versions_on_item_type_and_item_id"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "event_name", limit: 255
    t.date "event_start_date"
    t.date "event_end_date"
    t.integer "creator_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cannonical_event_id"
    t.integer "event_proposal_id"
    t.datetime "daily_start_time"
    t.datetime "daily_end_time"
    t.text "description"
    t.string "graced_by", limit: 255
    t.string "contact_details", limit: 255
    t.text "video_url"
    t.text "demand_draft_instructions"
    t.integer "status"
    t.integer "event_type_id"
    t.integer "payment_category"
    t.integer "total_capacity"
    t.string "contact_email", limit: 255
    t.string "website", limit: 255
    t.string "event_start_time", limit: 255
    t.string "event_end_time", limit: 255
    t.text "additional_details"
    t.integer "venue_type_id"
    t.boolean "is_photo_proof_required", default: false
    t.boolean "show_seats_availability", default: false
    t.string "event_location", limit: 255
    t.text "status_changes_notes"
    t.integer "master_event_id"
    t.boolean "is_club_event", default: false
    t.boolean "pre_approval_required", default: false
    t.text "registrations_recipients"
    t.boolean "show_shivir_price", default: false
    t.boolean "full_profile_needed", default: false
    t.boolean "pay_in_usd", default: false
    t.integer "entity_type"
    t.string "entity_key", limit: 255
    t.integer "event_cancellation_plan_id"
    t.integer "discount_plan_id"
    t.boolean "automatic_refund", default: true
    t.integer "sy_event_company_id"
    t.integer "reference_event_id"
    t.boolean "has_seva_preference", default: false
    t.string "approver_email", limit: 255
    t.string "logistic_email", limit: 255
    t.boolean "end_date_ignored", default: false
    t.text "prerequisite_message"
    t.boolean "notification_service", default: true
    t.boolean "shivir_card_enabled", default: false
    t.text "discount_text", default: ""
    t.string "slug"
    t.boolean "auto_approve", default: false
    t.boolean "next_financial_year", default: false
    t.integer "min_age_criteria"
    t.index ["discount_plan_id"], name: "index_events_on_discount_plan_id"
    t.index ["event_cancellation_plan_id"], name: "index_events_on_event_cancellation_plan_id"
    t.index ["event_type_id"], name: "index_events_on_event_type_id"
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["venue_type_id"], name: "index_events_on_venue_type_id"
  end

  create_table "extension_details", force: :cascade do |t|
    t.text "downloaded_assets"
    t.integer "sadhak_profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feedback_form_field_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forum_attendance_detail_versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.text "object"
    t.string "ip", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "whodunnit", limit: 255
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_forum_attendance_detail_versions_on_item_type_and_item_id"
  end

  create_table "forum_attendance_details", id: :serial, force: :cascade do |t|
    t.integer "digital_asset_id"
    t.integer "sy_club_id"
    t.datetime "conducted_on"
    t.integer "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "edit_count", default: 0
    t.integer "last_updated_by_id"
    t.text "venue", default: ""
    t.index ["deleted_at"], name: "index_forum_attendance_details_on_deleted_at"
    t.index ["digital_asset_id", "sy_club_id", "conducted_on"], name: "index_forum_attendancedetails_on_d_asset_id_c_id_conducted_on"
    t.index ["digital_asset_id"], name: "index_forum_attendance_details_on_digital_asset_id"
    t.index ["sy_club_id"], name: "index_forum_attendance_details_on_sy_club_id"
  end

  create_table "forum_attendance_versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.text "object"
    t.string "ip", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "whodunnit", limit: 255
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_forum_attendance_versions_on_item_type_and_item_id"
  end

  create_table "forum_attendances", id: :serial, force: :cascade do |t|
    t.integer "sadhak_profile_id"
    t.integer "sy_club_member_id"
    t.integer "forum_attendance_detail_id"
    t.boolean "is_attended", default: false
    t.datetime "deleted_at"
    t.integer "last_updated_by"
    t.boolean "is_current_forum_member"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_forum_attendances_on_deleted_at"
    t.index ["forum_attendance_detail_id"], name: "index_forum_attendances_on_forum_attendance_detail_id"
    t.index ["sadhak_profile_id"], name: "index_forum_attendances_on_sadhak_profile_id"
    t.index ["sy_club_member_id"], name: "index_forum_attendances_on_sy_club_member_id"
  end

  create_table "frequent_sadhna_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "global_preferences", id: :serial, force: :cascade do |t|
    t.string "key", limit: 255
    t.text "val"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "alias_name", limit: 255
    t.boolean "is_deleted", default: false
    t.integer "input_type"
    t.integer "group_name"
  end

  create_table "hdfc_configs", force: :cascade do |t|
    t.string "alias_name"
    t.string "working_key"
    t.string "merchant_id"
    t.string "access_code"
    t.integer "payment_gateway_id"
    t.integer "country_id"
    t.float "tax_amount"
  end

  create_table "image_versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.text "object"
    t.string "ip", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "whodunnit", limit: 255
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_image_versions_on_item_type_and_item_id"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "s3_url", limit: 255
    t.string "s3_path", limit: 255
    t.boolean "is_secure"
    t.string "s3_bucket", limit: 255
    t.integer "imageable_id"
    t.string "imageable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_images_on_deleted_at"
    t.index ["imageable_id", "imageable_type"], name: "index_images_on_imageable_id_and_imageable_type"
  end

  create_table "line_items", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "digital_asset_id"
    t.decimal "total_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["digital_asset_id"], name: "index_line_items_on_digital_asset_id"
    t.index ["order_id"], name: "index_line_items_on_order_id"
  end

  create_table "medical_practitioner_speciality_areas", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "medical_practitioners_profiles", id: :serial, force: :cascade do |t|
    t.string "medical_degree", limit: 255
    t.boolean "practiced_integrative_health_care"
    t.integer "current_professional_role"
    t.string "other_role", limit: 255
    t.integer "work_enviroment"
    t.boolean "interested_in_panel_discussion"
    t.boolean "interested_in_volunteering"
    t.string "other_speciality", limit: 255
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "medical_practitioner_speciality_area_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_medical_practitioners_profiles_on_deleted_at"
    t.index ["sadhak_profile_id"], name: "index_medical_practitioners_profiles_on_sadhak_profile_id"
  end

  create_table "merge_sadhaks", id: :serial, force: :cascade do |t|
    t.string "primary_sadhak_id"
    t.string "secondary_sadhak_id"
    t.string "merge_ref_number"
    t.text "meta_data"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_merge_sadhaks_on_user_id"
  end

  create_table "order_payment_informations", id: :serial, force: :cascade do |t|
    t.decimal "amount"
    t.string "billing_name", limit: 255
    t.text "billing_address"
    t.string "billing_address_city", limit: 255
    t.string "billing_address_postal_code", limit: 255
    t.string "billing_address_country", limit: 255
    t.string "billing_phone", limit: 255
    t.string "billing_email", limit: 255
    t.string "ccavenue_tracking_id", limit: 255
    t.string "ccavenue_failure_message", limit: 255
    t.string "ccavenue_payment_mode", limit: 255
    t.string "ccavenue_status_code", limit: 255
    t.string "billing_address_state", limit: 255
    t.string "ccavenue_status_identifier", limit: 255
    t.integer "status"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_order_id"
    t.integer "config_id"
    t.string "m_payment_id"
    t.index ["ccavenue_tracking_id"], name: "index_order_payment_informations_on_ccavenue_tracking_id"
    t.index ["event_order_id"], name: "index_order_payment_informations_on_event_order_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "status"
    t.string "billing_address", limit: 255
    t.string "billing_address_city", limit: 255
    t.string "billing_address_state", limit: 255
    t.string "billing_address_country", limit: 255
    t.string "billing_address_postal_code", limit: 255
    t.string "billing_phone", limit: 255
    t.string "billing_email", limit: 255
    t.string "billing_name", limit: 255
    t.string "currency", limit: 255
    t.decimal "total_amount"
    t.string "ccavenue_tracking_id", limit: 255
    t.string "ccavenue_failure_message", limit: 255
    t.string "ccavenue_payment_mode", limit: 255
    t.string "ccavenue_status_code", limit: 255
    t.string "ccavenue_status_message", limit: 255
    t.string "ccavenue_customer_identifier", limit: 255
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "final_line_items", limit: 255
    t.string "sbm_order_id", limit: 255
    t.string "sbm_merchant_order_num", limit: 255
    t.string "sbm_amount_paid", limit: 255
    t.text "sbm_response"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "other_spiritual_associations", id: :serial, force: :cascade do |t|
    t.string "organization_name", limit: 255
    t.string "association_description", limit: 255
    t.integer "associated_since_year"
    t.integer "associated_since_month"
    t.integer "duration_of_practice"
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_of_guru", limit: 255
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_other_spiritual_associations_on_deleted_at"
  end

  create_table "pandal_details", id: :serial, force: :cascade do |t|
    t.decimal "len", precision: 10, scale: 2
    t.decimal "width", precision: 10, scale: 2
    t.integer "seating_type"
    t.integer "matresses_count"
    t.integer "chairs_count"
    t.text "arrangement_details"
    t.integer "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_gateway_mode_association_ranges", force: :cascade do |t|
    t.float "min_value", default: 0.0
    t.float "max_value", default: ::Float::INFINITY
    t.float "percent", default: 0.0
    t.bigint "payment_gateway_mode_association_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_payment_gateway_mode_association_ranges_on_deleted_at"
    t.index ["payment_gateway_mode_association_id"], name: "index_pg_mode_ass_id_to_ranges"
  end

  create_table "payment_gateway_mode_association_tax_types", force: :cascade do |t|
    t.bigint "tax_type_id"
    t.bigint "payment_gateway_mode_association_id"
    t.float "percent", default: 0.0
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_payment_gateway_mode_association_tax_types_on_deleted_at"
    t.index ["payment_gateway_mode_association_id"], name: "index_pg_mode_ass_tax_types_on_pg_mode_ass_id"
    t.index ["tax_type_id"], name: "index_payment_gateway_mode_association_tax_types_on_tax_type_id"
  end

  create_table "payment_gateway_mode_associations", force: :cascade do |t|
    t.float "percent", default: 0.0
    t.integer "percent_type"
    t.bigint "payment_gateway_id"
    t.bigint "payment_mode_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_payment_gateway_mode_associations_on_deleted_at"
    t.index ["payment_gateway_id"], name: "index_payment_gateway_mode_associations_on_payment_gateway_id"
    t.index ["payment_mode_id"], name: "index_payment_gateway_mode_associations_on_payment_mode_id"
  end

  create_table "payment_gateway_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "config_model_name", limit: 255
    t.string "relation_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_gateways", id: :serial, force: :cascade do |t|
    t.integer "payment_gateway_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["payment_gateway_type_id"], name: "index_payment_gateways_on_payment_gateway_type_id"
  end

  create_table "payment_modes", force: :cascade do |t|
    t.string "name"
    t.string "shortcode"
    t.integer "group_name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_payment_modes_on_deleted_at"
  end

  create_table "payment_reconcilations", id: :serial, force: :cascade do |t|
    t.string "method", limit: 255
    t.string "reconcilation_ref_number", limit: 255
    t.string "file_name", limit: 255
    t.integer "status"
    t.string "user_id", limit: 255
    t.string "message", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_refund_line_items", id: :serial, force: :cascade do |t|
    t.integer "sadhak_profile_id"
    t.integer "event_registration_id"
    t.integer "status"
    t.integer "event_id"
    t.integer "event_seating_category_association_id"
    t.boolean "is_deleted", default: false
    t.integer "payment_refund_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_order_line_item_id"
    t.integer "old_item_status"
    t.integer "new_item_status"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_payment_refund_line_items_on_deleted_at"
    t.index ["event_id"], name: "index_payment_refund_line_items_on_event_id"
    t.index ["event_order_line_item_id"], name: "index_payment_refund_line_items_on_event_order_line_item_id"
    t.index ["event_registration_id"], name: "index_payment_refund_line_items_on_event_registration_id"
    t.index ["event_seating_category_association_id"], name: "index_payment_refund_line_items_on_seating_category_ass_id"
    t.index ["payment_refund_id"], name: "index_payment_refund_line_items_on_payment_refund_id"
    t.index ["sadhak_profile_id"], name: "index_payment_refund_line_items_on_sadhak_profile_id"
  end

  create_table "payment_refunds", id: :serial, force: :cascade do |t|
    t.integer "requester_id"
    t.integer "responder_id"
    t.decimal "amount_refunded", precision: 10, scale: 2, default: "0.0"
    t.integer "event_order_id"
    t.integer "event_id"
    t.integer "action"
    t.integer "status"
    t.boolean "is_deleted", default: false
    t.text "request_object"
    t.decimal "max_refundable_amount", precision: 10, scale: 2, default: "0.0"
    t.integer "event_cancellation_plan_id"
    t.string "ip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "shifted_event_order_id"
    t.decimal "policy_refundable_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "cancellation_charges", precision: 10, scale: 2, default: "0.0"
    t.integer "item_status"
    t.index ["event_cancellation_plan_id"], name: "index_payment_refunds_on_event_cancellation_plan_id"
    t.index ["event_id"], name: "index_payment_refunds_on_event_id"
    t.index ["event_order_id"], name: "index_payment_refunds_on_event_order_id"
    t.index ["requester_id"], name: "index_payment_refunds_on_requester_id"
    t.index ["responder_id"], name: "index_payment_refunds_on_responder_id"
    t.index ["shifted_event_order_id"], name: "index_payment_refunds_on_shifted_event_order_id"
  end

  create_table "pg_cash_payment_transactions", id: :serial, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.integer "status"
    t.date "payment_date"
    t.boolean "is_terms_accepted", default: false
    t.text "additional_details"
    t.string "transaction_number", limit: 255
    t.integer "event_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sy_club_id"
    t.index ["event_order_id"], name: "index_pg_cash_payment_transactions_on_event_order_id"
    t.index ["sy_club_id"], name: "index_pg_cash_payment_transactions_on_sy_club_id"
    t.index ["transaction_number"], name: "index_pg_cash_payment_transactions_on_transaction_number"
  end

  create_table "pg_sy_braintree_configs", id: :serial, force: :cascade do |t|
    t.string "publishable_key", limit: 255
    t.string "secret_key", limit: 255
    t.string "alias_name", limit: 255
    t.string "merchant_id", limit: 255
    t.integer "country_id"
    t.float "tax_amount"
    t.integer "payment_gateway_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["payment_gateway_id"], name: "index_pg_sy_braintree_configs_on_payment_gateway_id"
  end

  create_table "pg_sy_braintree_payments", id: :serial, force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency_iso_code", limit: 255
    t.string "braintree_payment_id", limit: 255
    t.string "refund_ids", limit: 255
    t.string "refunded_transaction_id", limit: 255
    t.integer "status"
    t.integer "event_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sy_club_id"
    t.integer "config_id"
    t.index ["braintree_payment_id"], name: "index_pg_sy_braintree_payments_on_braintree_payment_id"
    t.index ["event_order_id"], name: "index_pg_sy_braintree_payments_on_event_order_id"
    t.index ["sy_club_id"], name: "index_pg_sy_braintree_payments_on_sy_club_id"
  end

  create_table "pg_sy_hdfc_payments", force: :cascade do |t|
    t.decimal "amount"
    t.string "billing_name"
    t.text "billing_address"
    t.string "billing_address_city"
    t.string "billing_address_postal_code"
    t.string "billing_address_country"
    t.string "billing_phone"
    t.string "billing_email"
    t.string "hdfc_tracking_id"
    t.string "hdfc_failure_message"
    t.string "hdfc_payment_mode"
    t.string "hdfc_status_code"
    t.string "billing_address_state"
    t.string "hdfc_status_identifier"
    t.integer "status"
    t.integer "user_id"
    t.integer "event_order_id"
    t.integer "config_id"
    t.string "m_payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hdfc_tracking_id"], name: "index_pg_sy_hdfc_payments_on_hdfc_tracking_id"
  end

  create_table "pg_sy_payfast_configs", id: :serial, force: :cascade do |t|
    t.string "user_name", limit: 255
    t.string "alias_name", limit: 255
    t.string "merchant_id", limit: 255
    t.string "merchant_key", limit: 255
    t.integer "payment_gateway_id"
    t.integer "pdt"
    t.string "pdt_key", limit: 255
    t.integer "country_id"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.boolean "is_deleted", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["payment_gateway_id"], name: "index_pg_sy_payfast_configs_on_payment_gateway_id"
  end

  create_table "pg_sy_payfast_payments", id: :serial, force: :cascade do |t|
    t.string "name_first", limit: 255
    t.string "name_last", limit: 255
    t.string "email_address", limit: 255
    t.string "m_payment_id", limit: 255
    t.decimal "amount", precision: 10, scale: 2, default: "0.0"
    t.string "item_description", limit: 255
    t.string "signature", limit: 255
    t.integer "event_order_id"
    t.integer "sy_club_id"
    t.integer "status"
    t.string "pf_payment_id", limit: 255
    t.decimal "amount_fee", precision: 10, scale: 2, default: "0.0"
    t.decimal "amount_net", precision: 10, scale: 2, default: "0.0"
    t.decimal "amount_gross", precision: 10, scale: 2, default: "0.0"
    t.string "currency", limit: 255
    t.integer "config_id"
    t.boolean "is_deleted", default: false
    t.boolean "processed", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_order_id"], name: "index_pg_sy_payfast_payments_on_event_order_id"
    t.index ["pf_payment_id"], name: "index_pg_sy_payfast_payments_on_pf_payment_id"
    t.index ["sy_club_id"], name: "index_pg_sy_payfast_payments_on_sy_club_id"
  end

  create_table "pg_sy_paypal_configs", id: :serial, force: :cascade do |t|
    t.string "username", limit: 255
    t.string "password", limit: 255
    t.string "signature", limit: 255
    t.integer "country_id"
    t.float "tax_amount"
    t.string "alias_name", limit: 255
    t.string "publishable_key", limit: 255
    t.string "secret_key", limit: 255
    t.integer "merchant_id"
    t.integer "payment_gateway_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["payment_gateway_id"], name: "index_pg_sy_paypal_configs_on_payment_gateway_id"
  end

  create_table "pg_sy_paypal_payments", id: :serial, force: :cascade do |t|
    t.integer "amount"
    t.integer "event_order_id"
    t.integer "status"
    t.string "transaction_id", limit: 255
    t.string "invoice_number", limit: 255
    t.string "token", limit: 255
    t.string "redirect_url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "currency_code", limit: 255
    t.string "correlation_id", limit: 255
    t.integer "sy_club_id"
    t.integer "config_id"
    t.index ["sy_club_id"], name: "index_pg_sy_paypal_payments_on_sy_club_id"
    t.index ["transaction_id"], name: "index_pg_sy_paypal_payments_on_transaction_id"
  end

  create_table "pg_sy_razorpay_configs", id: :serial, force: :cascade do |t|
    t.string "publishable_key", limit: 255
    t.string "secret_key", limit: 255
    t.string "alias_name", limit: 255
    t.string "merchant_id", limit: 255
    t.integer "country_id"
    t.float "tax_amount"
    t.integer "payment_gateway_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["payment_gateway_id"], name: "index_pg_sy_razorpay_configs_on_payment_gateway_id"
  end

  create_table "pg_sy_razorpay_payments", id: :serial, force: :cascade do |t|
    t.string "entity", limit: 255
    t.string "currency", limit: 255
    t.string "description", limit: 255
    t.string "refund_status", limit: 255
    t.string "notes", limit: 255
    t.integer "pg_sy_razorpay_merchant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "razorpay_payment_id", limit: 255
    t.string "refund_id", limit: 255
    t.decimal "amount", precision: 10, scale: 2
    t.decimal "amount_refunded", precision: 10, scale: 2
    t.integer "status"
    t.integer "event_order_id"
    t.integer "sy_club_id"
    t.integer "config_id"
    t.index ["event_order_id"], name: "index_pg_sy_razorpay_payments_on_event_order_id"
    t.index ["razorpay_payment_id"], name: "index_pg_sy_razorpay_payments_on_razorpay_payment_id"
    t.index ["sy_club_id"], name: "index_pg_sy_razorpay_payments_on_sy_club_id"
  end

  create_table "pg_sydd_configs", id: :serial, force: :cascade do |t|
    t.string "public_key", limit: 255
    t.string "private_key", limit: 255
    t.integer "pg_sydd_merchant_id"
    t.integer "payment_gateway_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "alias_name", limit: 255
    t.integer "country_id"
    t.float "tax_amount"
    t.index ["payment_gateway_id"], name: "index_pg_sydd_configs_on_payment_gateway_id"
    t.index ["pg_sydd_merchant_id"], name: "index_pg_sydd_configs_on_pg_sydd_merchant_id"
  end

  create_table "pg_sydd_merchants", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "domain", limit: 255
    t.string "email", limit: 255
    t.string "mobile", limit: 255
    t.boolean "email_enabled"
    t.boolean "sms_enabled"
    t.integer "sms_limit"
    t.string "public_key", limit: 255
    t.string "private_key", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pg_sydd_transactions", id: :serial, force: :cascade do |t|
    t.string "dd_number", limit: 255
    t.integer "pg_sydd_merchant_id"
    t.date "dd_date"
    t.string "bank_name", limit: 255
    t.decimal "amount", precision: 10, scale: 2
    t.text "additional_details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_terms_accepted"
    t.integer "status"
    t.integer "event_order_id"
    t.integer "sy_club_id"
    t.index ["dd_number"], name: "index_pg_sydd_transactions_on_dd_number"
    t.index ["pg_sydd_merchant_id"], name: "index_pg_sydd_transactions_on_pg_sydd_merchant_id"
    t.index ["sy_club_id"], name: "index_pg_sydd_transactions_on_sy_club_id"
  end

  create_table "pg_sywiretransfer_merchants", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "domain", limit: 255
    t.string "email", limit: 255
    t.string "mobile", limit: 255
    t.boolean "email_enabled"
    t.boolean "sms_enabled"
    t.integer "sms_limit"
    t.string "public_key", limit: 255
    t.string "private_key", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pg_sywiretransfer_transactions", id: :serial, force: :cascade do |t|
    t.date "date_of_transaction"
    t.decimal "amount", precision: 10, scale: 2
    t.string "bank_reference_id", limit: 255
    t.string "remitters_bank_details", limit: 255
    t.string "beneficiary_bank_details", limit: 255
    t.string "currency", limit: 255
    t.integer "pg_sywiretransfer_merchant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo_id_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_exercise_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "professional_details", id: :serial, force: :cascade do |t|
    t.integer "highest_degree"
    t.string "occupation", limit: 255
    t.string "designation", limit: 255
    t.string "industry", limit: 255
    t.integer "profession_id"
    t.string "area_of_specialization", limit: 255
    t.string "other_profession", limit: 255
    t.string "name_of_organization", limit: 255
    t.integer "years_of_experience"
    t.string "personal_interests", limit: 255
    t.string "hobbies", limit: 255
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "professional_specialization", limit: 255
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_professional_details_on_deleted_at"
  end

  create_table "professions", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 255
  end

  create_table "purchased_digital_assets", id: :serial, force: :cascade do |t|
    t.integer "digital_asset_id"
    t.integer "user_id"
    t.string "promo_code_used", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["digital_asset_id"], name: "index_purchased_digital_assets_on_digital_asset_id"
    t.index ["promo_code_used"], name: "index_purchased_digital_assets_on_promo_code_used"
    t.index ["user_id"], name: "index_purchased_digital_assets_on_user_id"
  end

  create_table "registration_center_users", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "registration_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_registration_center_users_on_deleted_at"
  end

  create_table "registration_centers", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_cash_allowed", default: false
    t.string "start_date", limit: 255
    t.string "end_date", limit: 255
  end

  create_table "relations", id: :serial, force: :cascade do |t|
    t.string "syid", limit: 255
    t.string "relationship_type", limit: 255
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.boolean "is_verified"
    t.string "verification_code", limit: 255
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_relations_on_deleted_at"
    t.index ["user_id", "sadhak_profile_id"], name: "index_relations_on_user_id_and_sadhak_profile_id"
  end

  create_table "report_master_field_associations", id: :serial, force: :cascade do |t|
    t.integer "report_master_id"
    t.integer "report_master_field_id"
    t.text "proc_block"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_report_master_field_associations_on_deleted_at"
    t.index ["report_master_field_id"], name: "index_report_master_field_ass_on_report_master_field_id"
    t.index ["report_master_id"], name: "index_report_master_field_associations_on_report_master_id"
  end

  create_table "report_master_fields", id: :serial, force: :cascade do |t|
    t.string "field_name", limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_report_master_fields_on_deleted_at"
  end

  create_table "report_masters", id: :serial, force: :cascade do |t|
    t.string "report_name", limit: 255
    t.text "required_params"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "start_block"
    t.text "final_block"
    t.index ["deleted_at"], name: "index_report_masters_on_deleted_at"
  end

  create_table "role_dependencies", id: :serial, force: :cascade do |t|
    t.integer "user_role_id"
    t.date "start_date"
    t.date "end_date"
    t.boolean "is_restriction", default: false
    t.integer "whodunnit"
    t.datetime "deleted_at"
    t.string "role_dependable_type"
    t.integer "role_dependable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_role_dependencies_on_deleted_at"
    t.index ["role_dependable_type", "role_dependable_id"], name: "index_role_dependencies_on_type_and_id"
    t.index ["user_role_id"], name: "index_role_dependencies_on_user_role_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "description", limit: 255
    t.date "expiry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer "whodunnit"
    t.integer "role_type"
    t.index ["deleted_at"], name: "index_roles_on_deleted_at"
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "sadhak_asset_access_associations", force: :cascade do |t|
    t.string "sadhak_profile_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "access_from_date"
    t.date "access_to_date"
    t.bigint "collection_id"
    t.index ["collection_id"], name: "index_sadhak_asset_access_associations_on_collection_id"
  end

  create_table "sadhak_profile_attended_shivirs", id: :serial, force: :cascade do |t|
    t.string "shivir_name", limit: 255
    t.string "place", limit: 255
    t.string "month", limit: 255
    t.string "year", limit: 255
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sadhak_profile_attended_shivirs_on_deleted_at"
    t.index ["sadhak_profile_id"], name: "index_sadhak_profile_attended_shivirs_on_sadhak_profile_id"
  end

  create_table "sadhak_profile_satsang_associations", id: :serial, force: :cascade do |t|
    t.integer "sadhak_profile_id"
    t.integer "satsang_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sadhak_profile_satsang_associations_on_deleted_at"
  end

  create_table "sadhak_profile_versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.text "object"
    t.string "ip", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "whodunnit", limit: 255
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_sadhak_profile_versions_on_item_type_and_item_id"
  end

  create_table "sadhak_profiles", id: :serial, force: :cascade do |t|
    t.string "syid", limit: 255
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "middle_name", limit: 255
    t.string "gender", limit: 255
    t.string "marital_status", limit: 255
    t.integer "faith"
    t.boolean "any_legal_proceedings"
    t.boolean "attended_any_shivir"
    t.integer "photo_id_proof"
    t.integer "address_proof"
    t.integer "user_id"
    t.integer "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "avatar_file_name", limit: 255
    t.string "avatar_content_type", limit: 255
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.date "date_of_birth"
    t.string "occupation_type", limit: 255
    t.string "mobile", limit: 255
    t.string "phone", limit: 255
    t.string "email", limit: 255
    t.boolean "is_mobile_verified", default: false
    t.string "mobile_verification_token", limit: 255
    t.boolean "is_email_verified"
    t.string "email_verification_token", limit: 255
    t.string "ownership_request_token", limit: 255
    t.float "profile_completeness"
    t.boolean "is_approved_for_mega_events", default: false
    t.boolean "is_approved_for_virtual_events", default: false
    t.string "username", limit: 255
    t.integer "profile_photo_status"
    t.integer "photo_id_status"
    t.integer "address_proof_status"
    t.boolean "is_under_age", default: false
    t.integer "visit_id"
    t.string "name_of_guru", limit: 255
    t.string "spiritual_org_name", limit: 255
    t.datetime "deleted_at"
    t.string "slug"
    t.string "avatar"
    t.index ["deleted_at"], name: "index_sadhak_profiles_on_deleted_at"
    t.index ["slug"], name: "index_sadhak_profiles_on_slug", unique: true
  end

  create_table "sadhak_seva_preferences", id: :serial, force: :cascade do |t|
    t.text "voluntary_organisation"
    t.integer "seva_preference"
    t.string "other_seva_preference", limit: 255
    t.integer "availability"
    t.integer "sadhak_profile_id"
    t.string "expertise", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sadhak_seva_preferences_on_deleted_at"
  end

  create_table "satsang_center_organizer_associations", id: :serial, force: :cascade do |t|
    t.integer "satsang_center_id"
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_satsang_center_organizer_associations_on_deleted_at"
  end

  create_table "satsang_centers", id: :serial, force: :cascade do |t|
    t.integer "region_id"
    t.integer "approver_user_id"
    t.string "satsang_frequency", limit: 255
    t.datetime "satsang_cannonical_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "digital_asset_id"
  end

  create_table "seating_categories", id: :serial, force: :cascade do |t|
    t.string "category_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "category_colour", limit: 255
  end

  create_table "shivyog_change_logs", id: :serial, force: :cascade do |t|
    t.string "attribute_name", limit: 255
    t.string "value_before", limit: 255
    t.string "value_after", limit: 255
    t.string "description", limit: 255
    t.integer "change_loggable_id"
    t.string "change_loggable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "whodunnit"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_shivyog_change_logs_on_deleted_at"
    t.index ["whodunnit"], name: "index_shivyog_change_logs_on_whodunnit"
  end

  create_table "shivyog_journeys", id: :serial, force: :cascade do |t|
    t.string "source_of_information", limit: 255
    t.string "tv_channels", limit: 255
    t.string "reason_for_joining", limit: 255
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_shivyog_journeys_on_deleted_at"
  end

  create_table "shivyog_teachings", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "source_info_types", id: :serial, force: :cascade do |t|
    t.string "source_name", limit: 255
    t.boolean "is_deleted", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "special_event_sadhak_profile_other_infos", id: :serial, force: :cascade do |t|
    t.integer "sadhak_profile_id"
    t.integer "event_order_line_item_id"
    t.integer "event_id"
    t.string "father_name", limit: 255
    t.string "mother_name", limit: 255
    t.boolean "are_you_member_of_political_party"
    t.string "political_party_name", limit: 255
    t.string "how_long_associated_with_shivyog", limit: 255
    t.string "yearly_renumaration", limit: 255
    t.string "languages", limit: 255
    t.boolean "are_you_taking_medication"
    t.text "medication_details"
    t.boolean "are_you_suffering_from_physical_or_mental_ailments"
    t.text "ailment_details"
    t.boolean "are_you_involved_in_any_litigation_cases"
    t.text "case_details"
    t.text "why_you_want_to_attend_this_shivir"
    t.text "how_did_you_came_to_know_about_the_shivir"
    t.boolean "would_you_like_to_participate_in_the_devine_mission_of_shivyog"
    t.text "participation_details"
    t.text "accepted_terms_and_conditions"
    t.string "signature", limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_special_event_sadhak_profile_other_infos_on_deleted_at"
    t.index ["event_id"], name: "fk_special_event_sp_other_info_event_id"
    t.index ["event_order_line_item_id"], name: "fk_special_event_sp_other_info_line_item_id"
    t.index ["sadhak_profile_id"], name: "fk_special_event_sp_other_info_sadhak_id"
  end

  create_table "special_event_sadhak_profile_references", id: :serial, force: :cascade do |t|
    t.integer "special_event_sadhak_profile_other_info_id"
    t.integer "sadhak_profile_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_special_event_sadhak_profile_references_on_deleted_at"
    t.index ["sadhak_profile_id"], name: "fk_sadhak_id_on_special_event_sadhak_profile_references"
    t.index ["special_event_sadhak_profile_other_info_id"], name: "fk_special_event_sp_other_info_to_references"
  end

  create_table "spiritual_journeys", id: :serial, force: :cascade do |t|
    t.string "source_of_information", limit: 255
    t.text "reason_for_joining"
    t.string "first_event_attended", limit: 255
    t.integer "first_event_attended_year"
    t.integer "first_event_attended_month"
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sub_source_type_id"
    t.text "alternative_source"
    t.datetime "deleted_at"
    t.integer "source_info_type_id"
    t.index ["deleted_at"], name: "index_spiritual_journeys_on_deleted_at"
    t.index ["sub_source_type_id"], name: "index_spiritual_journeys_on_sub_source_type_id"
  end

  create_table "spiritual_practice_frequent_sadhna_type_associations", id: :serial, force: :cascade do |t|
    t.integer "spiritual_practice_id"
    t.integer "frequent_sadhna_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sp_frequent_sadhna_type_assoc_on_deleted_at"
  end

  create_table "spiritual_practice_physical_exercise_type_associations", id: :serial, force: :cascade do |t|
    t.integer "spiritual_practice_id"
    t.integer "physical_exercise_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sp_physical_exercise_type_assoc_on_deleted_at"
  end

  create_table "spiritual_practice_shivyog_teaching_associations", id: :serial, force: :cascade do |t|
    t.integer "spiritual_practice_id"
    t.integer "shivyog_teaching_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sp_shivyog_teaching_assoc_on_deleted_at"
  end

  create_table "spiritual_practices", id: :serial, force: :cascade do |t|
    t.integer "morning_sadha_duration_hours"
    t.integer "afternoon_sadha_duration_hours"
    t.integer "evening_sadha_duration_hours"
    t.integer "other_sadha_duration_hours"
    t.integer "sadhana_frequency_days_per_week"
    t.string "frequent_sadhana_type", limit: 255
    t.string "physical_exercise_type", limit: 255
    t.string "shivyog_teachings_applied_in_life", limit: 255
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "frequency_period", limit: 255
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_spiritual_practices_on_deleted_at"
  end

  create_table "stripe_configs", id: :serial, force: :cascade do |t|
    t.string "publishable_key", limit: 255
    t.string "secret_key", limit: 255
    t.string "alias_name", limit: 255
    t.string "merchant_id", limit: 255
    t.integer "payment_gateway_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "country_id"
    t.float "tax_amount"
    t.index ["payment_gateway_id"], name: "index_stripe_configs_on_payment_gateway_id"
  end

  create_table "stripe_subscriptions", id: :serial, force: :cascade do |t|
    t.string "description", limit: 255
    t.integer "plan"
    t.string "card", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_order_id"
    t.string "customer_id", limit: 255
    t.decimal "amount", precision: 10, scale: 2
    t.integer "status"
    t.string "email", limit: 255
    t.string "charge_id", limit: 255
    t.string "refund_id", limit: 255
    t.integer "sy_club_id"
    t.integer "config_id"
    t.index ["card"], name: "index_stripe_subscriptions_on_card"
    t.index ["event_order_id"], name: "index_stripe_subscriptions_on_event_order_id"
    t.index ["sy_club_id"], name: "index_stripe_subscriptions_on_sy_club_id"
  end

  create_table "sub_source_types", id: :serial, force: :cascade do |t|
    t.integer "source_info_type_id"
    t.string "sub_source_name", limit: 255
    t.boolean "is_deleted", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["source_info_type_id"], name: "index_sub_source_types_on_source_info_type_id"
  end

  create_table "sy_club_digital_arrangement_details", id: :serial, force: :cascade do |t|
    t.integer "lcd_size"
    t.string "lcd_model", limit: 255
    t.integer "speakers_count"
    t.string "speaker_model", limit: 255
    t.string "dvd_player_model", limit: 255
    t.string "generator_company", limit: 255
    t.string "inverter_company", limit: 255
    t.boolean "is_laptop_available"
    t.integer "sy_club_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "internet_provider", limit: 255
    t.string "internet_speed", limit: 255
    t.string "internet_data_plan", limit: 255
    t.index ["sy_club_id"], name: "index_sy_club_digital_arrangement_details_on_sy_club_id"
  end

  create_table "sy_club_event_associations", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "sy_club_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_sy_club_event_associations_on_event_id"
    t.index ["sy_club_id"], name: "index_sy_club_event_associations_on_sy_club_id"
  end

  create_table "sy_club_event_type_associations", id: :serial, force: :cascade do |t|
    t.integer "sy_club_id"
    t.integer "event_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "status"
  end

  create_table "sy_club_member_action_details", id: :serial, force: :cascade do |t|
    t.integer "action_type"
    t.integer "from_status"
    t.integer "to_status"
    t.integer "sadhak_profile_id"
    t.integer "from_sy_club_member_id"
    t.integer "to_sy_club_member_id"
    t.integer "from_event_registration_id"
    t.integer "to_event_registration_id"
    t.text "action_reason"
    t.integer "requester_id"
    t.integer "responder_id"
    t.boolean "is_deleted", default: false
    t.datetime "action_time"
    t.integer "status"
    t.string "ip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["from_event_registration_id"], name: "index_member_action_details_on_from_event_registration_id"
    t.index ["from_sy_club_member_id"], name: "index_sy_club_member_action_details_on_from_sy_club_member_id"
    t.index ["requester_id"], name: "index_sy_club_member_action_details_on_requester_id"
    t.index ["responder_id"], name: "index_sy_club_member_action_details_on_responder_id"
    t.index ["to_event_registration_id"], name: "index_sy_club_member_action_details_on_to_event_registration_id"
    t.index ["to_sy_club_member_id"], name: "index_sy_club_member_action_details_on_to_sy_club_member_id"
  end

  create_table "sy_club_members", id: :serial, force: :cascade do |t|
    t.integer "sy_club_id"
    t.integer "sadhak_profile_id"
    t.integer "status"
    t.integer "sy_club_validity_window_id"
    t.string "guest_email", limit: 255
    t.datetime "club_joining_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "virtual_role"
    t.string "transaction_id", limit: 255
    t.string "payment_method", limit: 255
    t.integer "event_registration_id"
    t.boolean "is_deleted", default: false
    t.text "metadata"
    t.integer "transferred_to_club_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sy_club_members_on_deleted_at"
    t.index ["sadhak_profile_id"], name: "index_sy_club_members_on_sadhak_profile_id"
    t.index ["sy_club_id"], name: "index_sy_club_members_on_sy_club_id"
  end

  create_table "sy_club_payment_gateway_associations", id: :serial, force: :cascade do |t|
    t.integer "sy_club_id"
    t.integer "payment_gateway_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "payment_start_date"
    t.date "payment_end_date"
  end

  create_table "sy_club_references", id: :serial, force: :cascade do |t|
    t.integer "sy_club_id"
    t.integer "sadhak_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sy_club_references_on_deleted_at"
    t.index ["sadhak_profile_id"], name: "index_sy_club_references_on_sadhak_profile_id"
    t.index ["sy_club_id"], name: "index_sy_club_references_on_sy_club_id"
  end

  create_table "sy_club_sadhak_profile_associations", id: :serial, force: :cascade do |t|
    t.integer "sadhak_profile_id"
    t.integer "sy_club_id"
    t.integer "sy_club_user_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_joined", default: false
    t.integer "status"
    t.datetime "club_joining_date"
    t.integer "sy_club_validity_window_id"
    t.string "guest_email", limit: 255
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sy_club_sadhak_profile_associations_on_deleted_at"
    t.index ["sadhak_profile_id"], name: "index_sy_club_sadhak_profile_associations_on_sadhak_profile_id"
    t.index ["sy_club_id"], name: "index_sy_club_sadhak_profile_associations_on_sy_club_id"
  end

  create_table "sy_club_user_roles", id: :serial, force: :cascade do |t|
    t.string "role_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sy_club_validity_windows", id: :serial, force: :cascade do |t|
    t.date "club_reg_start_date"
    t.date "club_reg_end_date"
    t.date "membership_start_date"
    t.date "membership_end_date"
    t.integer "sy_club_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sy_club_sadhak_profile_association_id"
    t.index ["sy_club_id"], name: "index_sy_club_validity_windows_on_sy_club_id"
  end

  create_table "sy_club_venue_details", id: :serial, force: :cascade do |t|
    t.integer "venue_type"
    t.integer "room_size"
    t.integer "windows_count"
    t.integer "fans_count"
    t.integer "doors_count"
    t.string "room_color", limit: 255
    t.string "carpet_type", limit: 255
    t.integer "yantras_count"
    t.integer "sy_club_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "time", limit: 255
    t.string "room_other_activities", limit: 255
    t.string "painting_in_room", limit: 255
    t.string "lighting_arrangement", limit: 255
    t.index ["sy_club_id"], name: "index_sy_club_venue_details_on_sy_club_id"
  end

  create_table "sy_clubs", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "club_level"
    t.integer "members_count", default: 0
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "contact_details", limit: 255
    t.string "email", limit: 255
    t.integer "status"
    t.string "other_activity", limit: 255
    t.string "cultural_activities", limit: 255
    t.integer "old_forum_id"
    t.integer "old_venue_id"
    t.boolean "is_deleted", default: false
    t.text "metadata"
    t.integer "min_members_count", default: 10
    t.string "content_type", limit: 255, default: "english"
    t.string "slug"
    t.index ["slug"], name: "index_sy_clubs_on_slug", unique: true
    t.index ["user_id"], name: "index_sy_clubs_on_user_id"
  end

  create_table "sy_event_companies", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "llpin_number", limit: 255
    t.string "service_tax_number", limit: 255
    t.integer "last_invoice_number", default: 0
    t.text "terms_and_conditions"
    t.boolean "is_deleted", default: false
    t.boolean "automatic_invoice", default: false
    t.string "gstin_number"
    t.integer "last_refund_voucher_number", default: 0
    t.integer "last_receipt_voucher_number", default: 0
    t.integer "last_invoice_voucher_number", default: 0
    t.string "invoice_prefix"
    t.string "receipt_prefix"
    t.string "refund_prefix"
    t.integer "company_type"
  end

  create_table "sy_form_event_type_associations", id: :serial, force: :cascade do |t|
    t.integer "event_type_id"
    t.integer "sy_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_type_id"], name: "index_sy_form_event_type_associations_on_event_type_id"
    t.index ["sy_form_id"], name: "index_sy_form_event_type_associations_on_sy_form_id"
  end

  create_table "sy_form_field_associations", id: :serial, force: :cascade do |t|
    t.integer "sy_form_field_id"
    t.integer "sy_form_id"
    t.integer "form_field_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false
    t.index ["sy_form_field_id"], name: "index_sy_form_field_associations_on_sy_form_field_id"
    t.index ["sy_form_id"], name: "index_sy_form_field_associations_on_sy_form_id"
  end

  create_table "sy_form_field_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sy_form_fields", id: :serial, force: :cascade do |t|
    t.string "label", limit: 255
    t.text "default_value"
    t.string "placeholder", limit: 255
    t.boolean "is_required", default: false
    t.integer "sy_form_field_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "field_options", limit: 255
    t.index ["sy_form_field_type_id"], name: "index_sy_form_fields_on_sy_form_field_type_id"
  end

  create_table "sy_form_values", id: :serial, force: :cascade do |t|
    t.string "value", limit: 255
    t.integer "sy_form_id"
    t.integer "sy_form_field_id"
    t.integer "sy_form_value_storable_id"
    t.string "sy_form_value_storable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sy_form_field_id"], name: "index_sy_form_values_on_sy_form_field_id"
    t.index ["sy_form_id"], name: "index_sy_form_values_on_sy_form_id"
    t.index ["sy_form_value_storable_id", "sy_form_value_storable_type"], name: "index_to_sy_form_value_on_storable_id_and_type"
  end

  create_table "sy_forms", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "form_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tag_collections", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "priority"
    t.integer "menu_id", default: 0
    t.index ["menu_id"], name: "index_tag_collections_on_menu_id"
    t.index ["name"], name: "index_tag_collections_on_name"
  end

  create_table "task_associations", id: :serial, force: :cascade do |t|
    t.integer "parent_task_id"
    t.integer "child_task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.string "taskable_type", limit: 255
    t.integer "taskable_id"
    t.integer "status"
    t.text "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email", limit: 255
    t.text "final_block"
    t.text "opts"
    t.text "t_config"
    t.text "start_block"
  end

  create_table "tax_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_deleted", default: false
  end

  create_table "teachers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "title"
    t.text "bio"
    t.string "mobile"
    t.string "email"
    t.string "skype"
    t.string "facebook_profile"
    t.string "twitter_profile"
    t.string "linkedin_profile"
    t.string "pinterest_profile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ticket_groups", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticket_responses", id: :serial, force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "user_id"
    t.text "response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "status"
  end

  create_table "ticket_types", id: :serial, force: :cascade do |t|
    t.string "ticket_type", limit: 255
    t.integer "ticket_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tickets", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "assigned_user_id"
    t.string "status", limit: 255
    t.integer "ticket_type_id"
    t.string "title", limit: 255
    t.text "description"
    t.datetime "reopened_at"
    t.datetime "closed_at"
    t.integer "ticketable_id"
    t.string "ticketable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "priority"
    t.text "ticket_cc"
    t.index ["ticketable_id", "ticketable_type"], name: "index_tickets_on_ticketable_id_and_ticketable_type"
  end

  create_table "transaction_logs", id: :serial, force: :cascade do |t|
    t.integer "transaction_loggable_id"
    t.string "transaction_loggable_type", limit: 255
    t.text "gateway_request_object"
    t.text "gateway_response_object"
    t.integer "transaction_type"
    t.string "gateway_transaction_id", limit: 255
    t.text "other_detail"
    t.integer "gateway_type"
    t.string "gateway_name", limit: 255
    t.integer "status", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.string "ip", limit: 255
    t.text "request_params"
    t.integer "sy_pg_id"
    t.index ["transaction_loggable_id", "transaction_loggable_type"], name: "index_transaction_logs_on_id_type"
    t.index ["user_id"], name: "index_transaction_logs_on_user_id"
  end

  create_table "transferred_event_orders", id: :serial, force: :cascade do |t|
    t.integer "child_event_order_id"
    t.integer "parent_event_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_group_mappings", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "user_group_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_group_id"], name: "index_user_group_mappings_on_user_group_id"
    t.index ["user_id", "user_group_id"], name: "index_user_group_mappings_on_user_id_and_user_group_id", unique: true
    t.index ["user_id"], name: "index_user_group_mappings_on_user_id"
  end

  create_table "user_groups", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", id: :serial, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.integer "whodunnit"
    t.index ["deleted_at"], name: "index_user_roles_on_deleted_at"
    t.index ["role_id", "user_id"], name: "index_user_roles_on_role_id_and_user_id", unique: true
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "user_ticket_associations", id: :serial, force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_ticket_group_associations", id: :serial, force: :cascade do |t|
    t.integer "ticket_group_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
    t.string "spree_api_key", limit: 48
    t.integer "ship_address_id"
    t.integer "bill_address_id"
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email", limit: 255
    t.boolean "super_admin", default: false
    t.boolean "digital_store_admin", default: false
    t.string "last_name", limit: 255
    t.boolean "group_admin", default: false
    t.boolean "event_admin", default: false
    t.boolean "is_mobile_verified", default: false
    t.boolean "is_email_verified", default: false
    t.string "contact_number", limit: 255
    t.string "username", limit: 255
    t.integer "sadhak_profile_id"
    t.boolean "photo_approval_admin", default: false
    t.integer "country_id"
    t.date "date_of_birth"
    t.string "gender", limit: 255
    t.boolean "is_active", default: true
    t.boolean "club_admin", default: false
    t.string "authentication_token", limit: 255
    t.string "verification_code", limit: 255
    t.boolean "india_admin", default: false
    t.datetime "deleted_at"
    t.string "unconfirmed_mobile"
    t.string "oauth_provider"
    t.string "oauth_uid"
    t.string "oauth_image"
    t.index ["authentication_token"], name: "index_users_on_authentication_token"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["oauth_uid"], name: "index_users_on_oauth_uid", where: "(oauth_uid IS NOT NULL)"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "venue_types", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.string "whodunnit", limit: 255
    t.text "object"
    t.string "ip", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "visits", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "visitor_id"
    t.string "ip", limit: 255
    t.text "user_agent"
    t.text "referrer"
    t.text "landing_page"
    t.integer "user_id"
    t.string "referring_domain", limit: 255
    t.string "search_keyword", limit: 255
    t.string "browser", limit: 255
    t.string "os", limit: 255
    t.string "device_type", limit: 255
    t.integer "screen_height"
    t.integer "screen_width"
    t.string "country", limit: 255
    t.string "region", limit: 255
    t.string "city", limit: 255
    t.string "postal_code", limit: 255
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "utm_source", limit: 255
    t.string "utm_medium", limit: 255
    t.string "utm_term", limit: 255
    t.string "utm_content", limit: 255
    t.string "utm_campaign", limit: 255
    t.datetime "started_at"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

  create_table "vouchers", force: :cascade do |t|
    t.string "receiptable_type"
    t.bigint "receiptable_id"
    t.integer "voucher_type"
    t.string "voucher_number"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_vouchers_on_deleted_at"
    t.index ["receiptable_type", "receiptable_id"], name: "index_vouchers_on_receiptable_type_and_receiptable_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "db_cities", column: "city_id", name: "addresses_city_id_fk"
  add_foreign_key "addresses", "db_countries", column: "country_id", name: "addresses_country_id_fk"
  add_foreign_key "addresses", "db_states", column: "state_id", name: "addresses_state_id_fk"
  add_foreign_key "advance_profiles", "sadhak_profiles", name: "advance_profiles_sadhak_profile_id_fk"
  add_foreign_key "advisory_counsils", "sadhak_profiles"
  add_foreign_key "advisory_counsils", "sy_clubs"
  add_foreign_key "aspect_feedbacks", "aspects_of_lives", name: "aspect_feedbacks_aspects_of_life_id_fk"
  add_foreign_key "aspects_of_lives", "sadhak_profiles", name: "aspects_of_lives_sadhak_profile_id_fk"
  add_foreign_key "asset_group_mappings", "digital_assets", name: "asset_group_mappings_digital_asset_id_fk"
  add_foreign_key "asset_group_mappings", "user_groups", name: "asset_group_mappings_user_group_id_fk"
  add_foreign_key "asset_tags", "tag_collections", name: "fk_asset_tags_tag_collections"
  add_foreign_key "bhandara_details", "events", name: "bhandara_details_event_id_fk", on_delete: :cascade
  add_foreign_key "bhandara_items", "bhandara_details", name: "bhandara_items_bhandara_detail_id_fk", on_delete: :cascade
  add_foreign_key "ccavenue_configs", "payment_gateways", name: "ccavenue_configs_payment_gateway_id_fk"
  add_foreign_key "collection_event_type_associations", "collections"
  add_foreign_key "collection_event_type_associations", "event_types"
  add_foreign_key "db_cities", "db_countries", column: "country_id", name: "db_cities_country_id_fk"
  add_foreign_key "db_cities", "db_states", column: "state_id", name: "db_cities_state_id_fk"
  add_foreign_key "db_states", "db_countries", column: "country_id", name: "db_states_country_id_fk"
  add_foreign_key "digital_assets", "collections", name: "fk_digital_assets_collections", on_delete: :nullify
  add_foreign_key "digital_assets", "digital_asset_secrets", name: "fk_digital_assets_digital_asset_secrets"
  add_foreign_key "doctors_profiles", "sadhak_profiles", name: "doctors_profiles_sadhak_profile_id_fk"
  add_foreign_key "ds_asset_tag_collections", "ds_asset_tags", name: "ds_asset_tag_collections_ds_asset_tag_id_fk"
  add_foreign_key "ds_inventory_requests", "ds_product_inventory_requests", name: "ds_inventory_requests_ds_product_inventory_request_id_fk"
  add_foreign_key "ds_inventory_requests", "ds_products", name: "ds_inventory_requests_ds_product_id_fk"
  add_foreign_key "ds_product_asset_tag_associations", "ds_asset_tags", name: "ds_product_asset_tag_associations_ds_asset_tag_id_fk"
  add_foreign_key "ds_product_asset_tag_associations", "ds_products", name: "ds_product_asset_tag_associations_ds_product_id_fk"
  add_foreign_key "ds_product_inventories", "ds_products", name: "ds_product_inventories_ds_product_id_fk"
  add_foreign_key "ds_product_inventories", "ds_shops", name: "ds_product_inventories_ds_shop_id_fk"
  add_foreign_key "ds_product_inventory_requests", "ds_shops", name: "ds_product_inventory_requests_ds_shop_id_fk"
  add_foreign_key "ds_shops", "events", name: "ds_shops_event_id_fk"
  add_foreign_key "event_awarenesses", "event_awareness_types", name: "event_awarenesses_event_awareness_type_id_fk"
  add_foreign_key "event_awarenesses", "events", name: "event_awarenesses_event_id_fk", on_delete: :cascade
  add_foreign_key "event_cost_estimations", "events", name: "event_cost_estimations_event_id_fk", on_delete: :cascade
  add_foreign_key "event_digital_asset_associations", "digital_assets", name: "event_digital_asset_associations_digital_asset_id_fk"
  add_foreign_key "event_digital_asset_associations", "events", name: "event_digital_asset_associations_event_id_fk"
  add_foreign_key "event_discount_plan_associations", "discount_plans", name: "event_discount_plan_associations_discount_plan_id_fk"
  add_foreign_key "event_discount_plan_associations", "events", name: "event_discount_plan_associations_event_id_fk"
  add_foreign_key "event_payment_gateway_associations", "events", name: "event_payment_gateway_associations_event_id_fk"
  add_foreign_key "event_payment_gateway_associations", "payment_gateways", name: "event_payment_gateway_associations_payment_gateway_id_fk"
  add_foreign_key "event_references", "events", name: "event_references_event_id_fk", on_delete: :cascade
  add_foreign_key "event_references", "sadhak_profiles", name: "event_references_sadhak_profile_id_fk", on_delete: :cascade
  add_foreign_key "event_registration_center_associations", "events", name: "fk_erca_event"
  add_foreign_key "event_registration_center_associations", "registration_centers", name: "fk_erca_rgn_center"
  add_foreign_key "event_sadhak_questionnaires", "events"
  add_foreign_key "event_sadhak_questionnaires", "sadhak_profiles"
  add_foreign_key "event_sponsors", "events", name: "event_sponsors_event_id_fk", on_delete: :cascade
  add_foreign_key "event_sponsors", "sadhak_profiles", name: "event_sponsors_sadhak_profile_id_fk", on_delete: :cascade
  add_foreign_key "event_team_details", "events", name: "event_team_details_event_id_fk"
  add_foreign_key "event_team_details", "sadhak_profiles", name: "event_team_details_sadhak_profile_id_fk"
  add_foreign_key "event_type_digital_asset_associations", "digital_assets", name: "event_type_digital_asset_associations_digital_asset_id_fk"
  add_foreign_key "event_type_digital_asset_associations", "event_types", name: "event_type_digital_asset_associations_event_type_id_fk"
  add_foreign_key "event_type_pricings", "event_types", name: "event_type_pricings_event_type_id_fk"
  add_foreign_key "events", "event_types", name: "events_event_type_id_fk"
  add_foreign_key "line_items", "digital_assets", name: "fk_line_items_digital_assets"
  add_foreign_key "line_items", "orders", name: "fk_line_items_orders", on_delete: :cascade
  add_foreign_key "merge_sadhaks", "users"
  add_foreign_key "order_payment_informations", "users", name: "order_payment_informations_user_id_fk"
  add_foreign_key "orders", "users", name: "fk_orders_users"
  add_foreign_key "other_spiritual_associations", "sadhak_profiles", name: "other_spiritual_associations_sadhak_profile_id_fk"
  add_foreign_key "pandal_details", "events", name: "pandal_details_event_id_fk", on_delete: :cascade
  add_foreign_key "payment_gateways", "payment_gateway_types", name: "payment_gateways_payment_gateway_type_id_fk"
  add_foreign_key "payment_refunds", "users", column: "requester_id", name: "payment_refunds_requester_id_fk"
  add_foreign_key "payment_refunds", "users", column: "responder_id", name: "payment_refunds_responder_id_fk"
  add_foreign_key "pg_sy_paypal_configs", "payment_gateways", name: "pg_sy_paypal_configs_payment_gateway_id_fk"
  add_foreign_key "pg_sy_razorpay_configs", "payment_gateways", name: "pg_sy_razorpay_configs_payment_gateway_id_fk"
  add_foreign_key "pg_sydd_configs", "payment_gateways", name: "pg_sydd_configs_payment_gateway_id_fk"
  add_foreign_key "pg_sydd_configs", "pg_sydd_merchants", name: "pg_sydd_configs_pg_sydd_merchant_id_fk"
  add_foreign_key "professional_details", "sadhak_profiles", name: "professional_details_sadhak_profile_id_fk"
  add_foreign_key "purchased_digital_assets", "digital_assets", name: "fk_pda_digital_assets"
  add_foreign_key "purchased_digital_assets", "users", name: "fk_pda_users"
  add_foreign_key "registration_center_users", "registration_centers", name: "fk_rcu_registration_center"
  add_foreign_key "registration_center_users", "users", name: "fk_rcu_user"
  add_foreign_key "relations", "sadhak_profiles", name: "relations_sadhak_profile_id_fk"
  add_foreign_key "relations", "users", name: "relations_user_id_fk"
  add_foreign_key "sadhak_asset_access_associations", "collections"
  add_foreign_key "spiritual_journeys", "sadhak_profiles", name: "spiritual_journeys_sadhak_profile_id_fk"
  add_foreign_key "spiritual_practice_frequent_sadhna_type_associations", "frequent_sadhna_types", name: "fk_spfsta_frequent_sadhna_type"
  add_foreign_key "spiritual_practice_frequent_sadhna_type_associations", "spiritual_practices", name: "fk_spfsta_spiritual_practice"
  add_foreign_key "spiritual_practice_physical_exercise_type_associations", "physical_exercise_types", name: "fk_sppeta_frequent_physical_exercise_type"
  add_foreign_key "spiritual_practice_physical_exercise_type_associations", "spiritual_practices", name: "fk_sppeta_spiritual_practice"
  add_foreign_key "spiritual_practice_shivyog_teaching_associations", "shivyog_teachings", name: "fk_spsta_frequent_shivyog_teaching"
  add_foreign_key "spiritual_practice_shivyog_teaching_associations", "spiritual_practices", name: "fk_spsta_spiritual_practice"
  add_foreign_key "spiritual_practices", "sadhak_profiles", name: "spiritual_practices_sadhak_profile_id_fk"
  add_foreign_key "stripe_configs", "payment_gateways", name: "stripe_configs_payment_gateway_id_fk"
  add_foreign_key "sy_club_digital_arrangement_details", "sy_clubs", name: "sy_club_digital_arrangement_details_sy_club_id_fk"
  add_foreign_key "sy_club_event_associations", "events", name: "sy_club_event_associations_event_id_fk"
  add_foreign_key "sy_club_event_associations", "sy_clubs", name: "sy_club_event_associations_sy_club_id_fk"
  add_foreign_key "sy_club_event_type_associations", "event_types", name: "sy_club_event_type_associations_event_type_id_fk"
  add_foreign_key "sy_club_event_type_associations", "sy_clubs", name: "sy_club_event_type_associations_sy_club_id_fk"
  add_foreign_key "sy_club_member_action_details", "event_registrations", column: "from_event_registration_id", name: "sy_club_member_action_details_from_event_registration_id_fk"
  add_foreign_key "sy_club_member_action_details", "event_registrations", column: "to_event_registration_id", name: "sy_club_member_action_details_to_event_registration_id_fk"
  add_foreign_key "sy_club_member_action_details", "sy_club_members", column: "from_sy_club_member_id", name: "sy_club_member_action_details_from_sy_club_member_id_fk"
  add_foreign_key "sy_club_member_action_details", "sy_club_members", column: "to_sy_club_member_id", name: "sy_club_member_action_details_to_sy_club_member_id_fk"
  add_foreign_key "sy_club_member_action_details", "users", column: "requester_id", name: "sy_club_member_action_details_requester_id_fk"
  add_foreign_key "sy_club_member_action_details", "users", column: "responder_id", name: "sy_club_member_action_details_responder_id_fk"
  add_foreign_key "sy_club_members", "sadhak_profiles", name: "sy_club_members_sadhak_profile_id_fk"
  add_foreign_key "sy_club_members", "sy_clubs", name: "sy_club_members_sy_club_id_fk"
  add_foreign_key "sy_club_payment_gateway_associations", "payment_gateways", name: "sy_club_payment_gateway_associations_payment_gateway_id_fk"
  add_foreign_key "sy_club_payment_gateway_associations", "sy_clubs", name: "sy_club_payment_gateway_associations_sy_club_id_fk"
  add_foreign_key "sy_club_references", "sadhak_profiles", name: "sy_club_references_sadhak_profile_id_fk"
  add_foreign_key "sy_club_references", "sy_clubs", name: "sy_club_references_sy_club_id_fk"
  add_foreign_key "sy_club_sadhak_profile_associations", "sadhak_profiles", name: "sy_club_sadhak_profile_associations_sadhak_profile_id_fk"
  add_foreign_key "sy_club_sadhak_profile_associations", "sy_club_user_roles", name: "sy_club_sadhak_profile_associations_sy_club_user_role_id_fk"
  add_foreign_key "sy_club_sadhak_profile_associations", "sy_clubs", name: "sy_club_sadhak_profile_associations_sy_club_id_fk"
  add_foreign_key "sy_club_validity_windows", "sy_clubs", name: "sy_club_validity_windows_sy_club_id_fk"
  add_foreign_key "sy_club_venue_details", "sy_clubs", name: "sy_club_venue_details_sy_club_id_fk"
  add_foreign_key "sy_clubs", "users", name: "sy_clubs_user_id_fk"
  add_foreign_key "ticket_responses", "tickets", name: "ticket_responses_ticket_id_fk", on_delete: :cascade
  add_foreign_key "ticket_responses", "users", name: "ticket_responses_user_id_fk", on_delete: :cascade
  add_foreign_key "ticket_types", "ticket_groups", name: "ticket_types_ticket_group_id_fk", on_delete: :cascade
  add_foreign_key "tickets", "ticket_types", name: "tickets_ticket_type_id_fk"
  add_foreign_key "tickets", "users", column: "assigned_user_id", name: "tickets_assigned_user_id_fk"
  add_foreign_key "tickets", "users", name: "tickets_user_id_fk"
  add_foreign_key "user_group_mappings", "user_groups", name: "fk_ugm_user_groups", on_delete: :cascade
  add_foreign_key "user_group_mappings", "users", name: "fk_ugm_users", on_delete: :cascade
  add_foreign_key "user_ticket_associations", "tickets", name: "user_ticket_associations_ticket_id_fk", on_delete: :cascade
  add_foreign_key "user_ticket_associations", "users", name: "user_ticket_associations_user_id_fk", on_delete: :cascade
  add_foreign_key "user_ticket_group_associations", "ticket_groups", name: "user_ticket_group_associations_ticket_group_id_fk", on_delete: :cascade
  add_foreign_key "user_ticket_group_associations", "users", name: "user_ticket_group_associations_user_id_fk", on_delete: :cascade
end
