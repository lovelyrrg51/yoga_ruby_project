namespace :v1 do

  get 'progress_jobs/:job_id', to: 'delayed_job_progresses#show'

  put 'special_event_sadhak_profile_other_infos/update_details', to: 'special_event_sadhak_profile_other_infos#update_details'
  resources :special_event_sadhak_profile_other_infos, only: [:create]

  scope '/chrome' do
    get 'basic_user_details', to: 'users#basic_user_details'
  end

  scope module: :shivyog_club, path: :wp do
    get 'forum_content_types', to: 'sy_clubs#content_types'
    get 'sy_clubs', to: 'sy_clubs#wp_sy_clubs'
    get 'sy_clubs/:id', to: 'sy_clubs#wp_sy_club'
  end

  concern :forum_attendance_module do
    member do
      put :update_attendance
      get :edit_details
    end
    resources :forum_attendances, only: [:index, :update]
  end

  resources :forum_attendance_details, only: [:index, :create, :show], concerns: :forum_attendance_module

  scope '/wp' do
    get 'sadhak_profiles/search', to: 'sadhak_profiles#wp_sadhak_profile_search'
    get 'sadhak_profiles/:id', to: 'sadhak_profiles#wp_sadhak_profile'
    get 'event_types', to: 'event_types#wp_event_types'
    get 'event_meta_types', to: 'events#wp_event_meta_types'
    get 'events', to: 'events#wp_events'
    post 'reset_password', to: 'users#wp_reset_password'
    post 'update_password', to: 'users#update_password'
    get 'digital_assets', to: 'digital_assets#wp_digital_assets'
    get 'basic_user_details', to: 'users#basic_user_details'
    resources :forum_attendance_details, only: [:index, :create, :show], concerns: :forum_attendance_module
  end

  get '/wp_sadhak_profile/:id', to: 'sadhak_profiles#wp_sadhak_profile'

  resources :sy_club_member_action_details

  resources :report_master_field_associations

  resources :report_master_fields

  post 'report_masters/generate_report', to: 'report_masters#generate_report'
  resources :report_masters

  post "event_orders/edit_before_pay", to: "event_orders#edit_before_pay"

  get 'events/events_excel', to: 'events#events_excel'

  resources :sub_source_types

  resources :source_info_types

  get "registration_centers/rc_details", to: "registration_centers#rc_details"
  post "payment_reconcilations/reconcilation", to: "payment_reconcilations#reconcilation"

  get "payment_reconcilations/reconcilation_file", to: "payment_reconcilations#generate_reconcilation_file"

  resources :payment_reconcilations

  resources :pg_sy_payfast_payments
  scope 'pay_fast' do
    post 'paid',    to: 'pg_sy_payfast_payments#paid',      as: :payfast_paid
    get 'success',  to: 'pg_sy_payfast_payments#success',   as: :payfast_success
    get 'cancel',   to: 'pg_sy_payfast_payments#cancel',    as: :payfast_fail
    get 'redirect', to: 'pg_sy_payfast_payments#redirect',  as: :payfast_redirect
  end

  resources :pg_sy_payfast_configs

  resources :global_preferences, only: [:index, :show, :update]

  # For delayed job web view
  # match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]

  get "event_registrations/generate_sewa_report", to: "event_registrations#generate_sewa_report"

  post "event_orders/get_tax_details", to: "event_orders#get_tax_details"

  resources :shivyog_change_logs

  get 'sadhak_profiles/generate_card', to: 'sadhak_profiles#generate_card'
  get 'sadhak_profiles/upcoming_shivirs', to: 'sadhak_profiles#upcoming_shivirs'
  get "sadhak_profiles/banned_sadhak", to: "sadhak_profiles#banned_sadhak"

  get "event_registrations/invoice", to: "event_registrations#invoice"
  resources :event_discount_plan_associations

  resources :discount_plans

  resources :payment_refund_line_items

  resources :event_cancellation_plan_items

  resources :event_cancellation_plans

  get "payment_refunds/registration_changes_report", to: "payment_refunds#registration_changes_report"
  post "payment_refunds/refund", to: "payment_refunds#refund"
  resources :payment_refunds

  resources :sy_event_companies

  resources :sadhak_seva_preferences

  get "sadhak_profiles/generate_file", to: "sadhak_profiles#generate_file"

  resources :activity_event_type_pricing_associations
  post "users/request_reset_password", to: "users#request_reset_password"
  post "users/confirm_reset_password", to: "users#confirm_reset_password"
  post "sy_form_values/create_custom", to: "sy_form_values#create_custom"
  put "sy_form_values/update_custom", to: "sy_form_values#update_custom"
  resources :sy_form_values

  resources :sy_form_event_type_associations

  post "sy_form_field_associations/create_custom", to: "sy_form_field_associations#create_custom"
  put "sy_form_field_associations/update_custom", to: "sy_form_field_associations#update_custom"
  resources :sy_form_field_associations

  resources :sy_forms

  resources :event_type_pricings

  resources :sy_form_fields

  resources :sy_form_field_types

  resources :sadhak_profile_attended_shivirs

  post "transaction_logs/create_metadata", to: "transaction_logs#create_metadata"
  resources :transaction_logs

  resources :dashboard_widget_configs

  resources :pg_sy_paypal_configs

  resources :pg_sy_braintree_configs

  get "pg_sy_braintree_payments/braintree_token", to: "pg_sy_braintree_payments#braintree_token"
  resources :pg_sy_braintree_payments

  post "pg_sy_paypal_payments/paypal_express_checkout", to: "pg_sy_paypal_payments#paypal_express_checkout"
  post "pg_sy_paypal_payments/paypal_get_express_checkout_payment", to: "pg_sy_paypal_payments#paypal_get_express_checkout_payment"
  post "pg_sy_paypal_payments/paypal_do_express_checkout_payment", to: "pg_sy_paypal_payments#paypal_do_express_checkout_payment"
  post "pg_sy_paypal_payments/paypal_express_checkout_club", to: "pg_sy_paypal_payments#paypal_express_checkout_club"
  post "pg_sy_paypal_payments/paypal_do_express_checkout_payment_club", to: "pg_sy_paypal_payments#paypal_do_express_checkout_payment_club"
  resources :pg_sy_paypal_payments

  resources :pg_sy_razorpay_configs

  resources :pg_sy_razorpay_payments

  resources :sy_club_payment_gateway_associations

  namespace :shivyog_club do
    get 'sy_clubs/content_types', to: 'sy_clubs#content_types'
    post "sy_clubs/club_payment" => "sy_clubs#club_payment"
    resources :sy_clubs
    resources :sy_club_user_roles
    resources :sy_club_venue_details
    resources :sy_club_digital_arrangement_details
    resources :sy_club_sadhak_profile_associations
    resources :sy_club_references
    resources :sy_club_event_associations
    resources :sy_club_event_type_associations
    resources :sy_club_validity_windows
    resources :sy_club_members
    post "sy_clubs/join_club" => "sy_clubs#join_club"
    post "sy_clubs/forum_register" => "sy_clubs#forum_register"
    post 'sy_clubs/check_transfer' => 'sy_clubs#check_transfer'
    post 'sy_clubs/forum_transfer' => 'sy_clubs#forum_transfer'
  end


  resources :photo_id_types

  resources :address_proof_types

  resources :event_prerequisites_event_types

  resources :medical_practitioner_speciality_areas

  resources :medical_practitioners_profiles

  resources :stripe_configs

  resources :stripe_subscriptions

  resources :pages

  resources :pg_cash_payment_transactions

  resources :ccavenue_configs

  resources :order_payment_informations #for ccavenue payment

  resources :event_digital_asset_associations

  resources :event_type_digital_asset_associations

  resources :ds_inventory_requests

  resources :ds_product_inventory_requests

  resources :ds_product_inventories

  resources :ds_shops

  resources :ds_product_asset_tag_associations

  resources :ds_products

  resources :ds_product_details

  resources :ds_asset_tag_collections

  resources :ds_asset_tags

  resources :event_payment_gateway_associations

  resources :pg_sydd_configs

  resources :payment_gateways

  resources :payment_gateway_types

  resources :event_sponsors

  resources :event_references

  resources :attachments

  resources :event_team_details

  resources :event_tax_type_associations

  resources :tax_types

  resources :pg_sywiretransfer_transactions

  resources :pg_sywiretransfer_merchants

  resources :venue_types

  resources :pg_sydd_transactions

  resources :pg_sydd_merchants

  # Seesion routes
  get 'sessions/current', to: 'sessions#show'
  get 'sign_out', to: 'sessions#user_sign_out'
  post 'users/sign_in', to: 'sessions#new'

  # Wordpress login routes
  scope 'wp' do
    post 'login', to:  'sessions#wp_login'
    get 'current', to: 'sessions#wp_current_user'
  end

  get "users/test", to: 'users#test'
  post "users/reset_sadhak_password", to: 'users#reset_sadhak_password'
  post "users/assign_role_to_users", to: 'users#assign_role_to_users'
  get 'users/permissions', to: 'users#permissions'
  get :csrf, to: 'csrf#index'
  scope "/api" do
    resources :users
    put "/update_password", to: 'users#update_password'
    post "/reset_password", to: 'users#reset_password'
    post "/reset_user_password", to: 'users#reset_user_password'
    get "/test", to: 'users#test'
    post "/resend_confirmation_email", to: 'users#resend_confirmation_email'
  end
  scope "/util" do
    post :cc_encrypt, to: 'cc_encrypt#create'
    get :cc_encrypt, to: 'cc_encrypt#index'
    get :s3_new_bucket, to: 's3_new_bucket#index'
    get "vimeo/me/videos", to: 'vimeo#index'
    get "vimeo/video/:video_id", to: 'vimeo#view'
    post :sbm_payment_url, to: 'cc_encrypt#sbm_pay'
    post :sbm_pay_by_card, to: 'cc_encrypt#sbm_pay_by_card'
  end

  get "sadhak_profiles/search_syid_using_mobile_or_email" => "sadhak_profiles#search_syid_using_mobile_or_email"
  get "sadhak_profiles/:id/confirm_mobile_verification" => "sadhak_profiles#confirm_mobile_verification"
  get "sadhak_profiles/:id/request_mobile_verification" => "sadhak_profiles#request_mobile_verification"
  get "sadhak_profiles/:id/confirm_email_verification" => "sadhak_profiles#confirm_email_verification"
  get "sadhak_profiles/:id/request_email_verification" => "sadhak_profiles#request_email_verification"
  get "sadhak_profiles/me" => "sadhak_profiles#me"
  post "sadhak_profiles/request_own_profile", to: "sadhak_profiles#request_own_profile"
  post "sadhak_profiles/confirm_own_sadhak_profile", to: "sadhak_profiles#confirm_own_sadhak_profile"
  get "sadhak_profiles/:id/request_mobile_verification_twilio" => "sadhak_profiles#request_mobile_verification_twilio"
  post "sadhak_profiles/add_to_user" => "sadhak_profiles#add_to_user"
  post "sadhak_profiles/sadhak_profile_confirm_association" => "sadhak_profiles#sadhak_profile_confirm_association"
  post "sadhak_profiles/notify_sadhak_profiles", to: 'sadhak_profiles#notify_sadhak_profiles'
  get "sadhak_profiles/total_shivir_attended" => "sadhak_profiles#total_shivir_attended"
  get "sadhak_profiles/total_shivir_organised" => "sadhak_profiles#total_shivir_organised"
  resources :sadhak_profiles
  resources :addresses

  get 'paginated/events', to: 'events#paginated'
  get 'events/list', to: 'events#list'
  get 'events/i_card', to: 'events#i_card'
  post "events/bulk_upload" => "events#bulk_upload"
  post "events/forum_event" => "events#forum_event"
  resources :events do
    member do
      get 'replicate'
      get 'by_gender'
      get 'by_category'
      get 'by_mode_of_payment'
      get 'by_profession'
      get 'by_category_and_mode_of_payment'
      get 'payment_info'
      get 'payment_info_by_rc'
      get 'by_age_group'
      get 'by_previous_events_registered'
    end
    collection do
      post :update_ashram_residential_shivirs_dates
    end
  end
  resources :digital_assets do
    member do
      get 'download'
    end
    collection do
      get 'view/:video_id', to: 'digital_assets#view'
    end
  end
  resources :asset_tags
  resources :purchased_digital_assets
  resources :collections
  resources :relations
  resources :additional_information
  resources :spiritual_practice
  resources :other_spiritual_association
  resources :user_groups
  resources :seating_categories
  resources :event_seating_category_associations
  #Approve and reject for residential event
  get "event_orders/pre_approval_event_application" => "event_orders#pre_approval_event_application"
  get "event_orders/resend_pre_approval_email" => "event_orders#resend_pre_approval_email"
  get "event_orders/resend_transaction_receipt_email" => "event_orders#resend_transaction_receipt_email"
  get "event_orders/generate_csv" => "event_orders#generate_csv"
  get "event_registrations/generate_csv" => "event_registrations#generate_csv"
  get "event_orders/sbm_response" => "event_orders#sbm_response"
  get "event_orders/blessed_payment" => "event_orders#blessed_payment"
  get "event_registrations/ready_event_orders", to: "event_registrations#ready_event_orders"
  post "event_orders/check_order" => "event_orders#check_order"
  resources :event_orders
  resources :cannonical_events
  resources :ticket_responses
  post "tickets/reply" => "tickets#reply"
  post "tickets/emailcreate" => "tickets#emailcreate"

  get "tickets/test" => "tickets#test"
  resources :tickets
  resources :user_ticket_associations
  resources :user_ticket_group_associations
  resources :ticket_types
  resources :ticket_groups

  resources :event_registrations do
    collection do
      get 'count'
      get 'generate_csv_with_stream'
      get 'generate_excel_with_stream', to: 'event_registrations#generate_csv_with_stream'
      get 'generate_csv_direct_streaming_to_browser'
      get 'generate_csv_test'
    end
  end

  get "s3_thumbnails", to: 's3_thumbnails#index'
  resources :tag_collections
  resources :digital_asset_secrets
  get "digital_asset_secrets/:id" => "digital_asset_secrets#show"
  get "test_redirect" => "digital_assets#test"

  root :to => "home#index" #this is the dashboard page

  resource :inbox, :controller => 'inbox', :only => [:show,:create]
  get "/countries", to: "db_countries#index"
  get "states/country/:id", to: "db_states#country"
  get "cities/state/:id", to: "db_cities#state"
  resources :db_states
  resources :db_countries
  resources :db_cities
  post "images/upload_advance_profile_photograph", to: "images#upload_advance_profile_photograph"
  post "images/upload_advance_profile_identity_proof", to: "images#upload_advance_profile_identity_proof"
  post "images/upload_advance_profile_address_proof", to: "images#upload_advance_profile_address_proof"
  get "users/export_user", to: "users#export_user"
  get "users/csv_export_user", to: "users#csv_export_user"
  resources :images
  resources :registration_center_users
  resources :event_registration_center_associations
  resources :registration_centers
  resources :event_cost_estimations
  resources :event_awarenesses
  resources :event_awareness_types
  resources :bhandara_items
  resources :bhandara_details
  resources :pandal_details
  resources :event_types
  resources :professions
  resources :aspect_feedbacks
  resources :aspects_of_lives
  resources :spiritual_journeys
  resources :shivyog_teachings
  resources :physical_exercise_types
  resources :frequent_sadhna_types
  resources :spiritual_practices
  resources :advance_profiles
  resources :doctors_profiles
  resources :professional_details
  resources :other_spiritual_associations
  resources :event_order_line_items
  resources :charges
  post "event_orders/pay", to: "event_orders#pay"
  post "event_orders/payment_refunds", to: "event_orders#payment_refunds"
  post "event_orders/change_line_item_status", to: "event_orders#change_line_item_status"
  post "event_orders/registration_upgrades", to: "event_orders#registration_upgrades"
  post 'event_orders/refund_email', to: 'event_orders#send_refund_email'
  post 'event_orders/test_refund', to: 'event_orders#test_refund'
  post "order_payment_informations/:id/success" => "order_payment_informations#success"
  post "order_payment_informations/:id/cancel" => "order_payment_informations#cancel"
  get "users/request_mobile_verification" => "users#request_mobile_verification"
  get "users/confirm_mobile_verification" => "users#confirm_mobile_verification"
  get "users/request_email_verification" => "users#request_email_verification"
  get "users/confirm_email_verification" => "users#confirm_email_verification"

  match '*path', :to => 'base#routing_error', via: :all
end
