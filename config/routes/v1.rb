scope :v1, path: :v1 do
  resources :terms_and_conditions, only: [] do
    collection do
      get :event_register
      get :demand_draft_payment
      get :cash_payment
      get :online_payment
      get :sy_event_company
      get :forum
    end
  end

  scope '/forums' do
      resources :collections do
        resources :digital_assets do
        end
      end
  end

  scope '/admin' do
    resources :collections, only: [] do
      collection do
        get 'episodes_collections'
        post 'create_episodes_collection'
        get 'new_episodes_collection'
        get 'shivir_episode_access'
        get 'shivir_collections'
        get 'shivir_collections_access'
        get 'shivir_collections/new', to: 'collections#new_shivir_collections'
      end

      member do
        patch 'update_sadhak_asset_access'
        get 'update_assets_order'
      end

      get 'edit_episodes_collection'
      put 'update_episodes_collection'
      patch 'update_episodes_collection'
      delete 'destroy_episodes_collection'

      # # Index
      # get '/episodes', to: 'digital_assets#episodes', as: :episodes
      # # Create
      # post 'create_episode', to: 'digital_assets#create_episode', as: :create_episode
      # # Edit
      # get 'episodes/:id/edit', to: 'digital_assets#edit_episode', as: :edit_episode
      # # Update
      # put 'episodes/:id/update', to: 'digital_assets#update_episode', as: :update_episode
      # # Delete
      # delete 'episodes/:id/destroy_episode', to: 'digital_assets#destroy_episode', as: :destroy_episode, name_prefix: ''
    end

    resources :collection_event_type_associations, only: [:update]
  end

  resources :admin, only: [] do
    collection do
        get 'deleted_sadhak_profiles'
        post 'restore_sadhak_profile'
      get 'search_sadhak'
      get 'registration_invoices'
      get 'photo_approval_admin_panel'
      get 'export_photo_approval_list'
      get 'merge_syid'
      post 'match_merge_syid'
      get 'users_associated_with_provider'
      post 'change_users_associated_with_provider'
      resources :registration_centers, only: []  do
        collection do
          get :new_for_admin
          get :index_for_admin
          post :create_for_admin
        end
        member do
          get :edit_for_admin
          delete :destroy_for_admin
          patch :update_for_admin
        end
      end
      resources :event_types
      resources :seating_categories
      resources :frequent_sadhna_types
      resources :physical_exercise_types
      resources :shivyog_teachings
      resources :professions
      resources :venue_types
      resources :medical_practitioner_speciality_areas
      resources :address_proof_types
      resources :photo_id_types
      resources :sy_event_companies
      resources :payment_gateway_types, only: [:index]
      resources :payment_gateways
      resources :ccavenue_configs do
        resources :payment_gateway_mode_associations
        member do
          get :payment_modes
        end
      end
      resources :hdfc_configs
      resources :pg_sydd_configs
      resources :pg_sy_razorpay_configs
      resources :pg_sy_braintree_configs
      resources :pg_sy_paypal_configs
      resources :stripe_configs
      resources :pg_sy_payfast_configs
      resources :tax_types
      resources :dashboard_widget_configs
      resources :sy_club_validity_windows
      resources :event_cancellation_plans do
        resources :event_cancellation_plan_items
      end
      resources :discount_plans
      resources :source_info_types
      resources :db_countries do
        collection do
          get 'country_index_for_state'
          get 'country_index_for_state_city'
        end
        resources :db_states, except: [:index] do
          collection do
            get 'state_index_for_city'
            get 'index_for_admin'
          end
          resources :db_cities, except: [:index] do
            collection do
              get 'index_for_admin'
            end
          end
        end
      end
      resources :global_preferences
      resources :payment_modes
      get :authorizations
      get :update_authorization
      resources :sy_clubs, only: [] do
          collection do
              get :offline_forum_data_migration
          get :expired_forum_members
              post :migrate_offline_forum_data
          match :generate_expired_members_file, via: [:get, :post]
          end
      end
      get 'sadhaks_episodes'
    end
  end

  match 'admin', to: 'admin#merge_syid', via: :all

  resources :payment_reconcilations, only: [:create, :index] do
    member do
      get :generate_reconcilation_file
    end
  end

    resources :homes, only: [:index]
  get 'contact_us', to: 'homes#contact_us', as: 'contact_us'
  get 'about_shivyog', to: 'homes#about_shivyog', as: 'about_shivyog'
  get 'coming_soon', to: 'homes#coming_soon', as: 'coming_soon'
  get 'privacy_policy', to: 'homes#privacy_policy', as: 'privacy_policy'
  get 'refund_policy', to: 'homes#refund_policy', as: 'refund_policy'
  get 'terms_and_conditions', to: 'homes#terms_and_conditions', as: 'terms_and_conditions'
  scope 'pay_fast' do
    post 'paid',    to: 'pg_sy_payfast_payments#paid',      as: :payfast_paid
    get 'success/:order_id',  to: 'pg_sy_payfast_payments#success',   as: :payfast_success
    get 'cancel/:order_id',   to: 'pg_sy_payfast_payments#cancel',    as: :payfast_fail
    get 'redirect', to: 'pg_sy_payfast_payments#redirect',  as: :payfast_redirect
  end

  resources :report_masters, only: [] do
    member do
      get :generate_report
      post :process_report
    end
  end

  resources :event_registrations, only: [] do

    member do
      get :event_registration_detail
      get :generate_voucher
    end
    collection do
      get :generate_csv
      get :generate_sewa_report
    end
  end




  scope :admin do
    resources :sadhak_profiles, only: [] do

      collection do
        get :new_message
        post :send_message
        match :generate_file, via: [:get, :post]
      end

      member do
        get :reset_user_password
        get :reset_and_send_user_password
        get :shivir_info
        get :forum_info
        get :profile_details
        get :edit_sadhak_profile_photo
        patch :update_sadhak_profile_photo
        get :change_sadhak_profile_status
        patch :update_sadhak_profile_status
        get :sadhak_profile_logs
        get :role_assignment_to_sadhak_profile_user
        post :assign_role_to_sadhak_profile_user
      end
    end
  end
  # get 'sadhak_profiles/simple_search', to: 'sadhak_profiles#simple_search'
  resources :sadhak_profiles, only: [:simple_search, :generate_card, :update, :edit, :show, :new, :create, :destroy] do
    resources :sadhak_profile_attended_shivirs, only:[:create, :update, :destroy]
    resources :other_spiritual_associations, only:[:create, :update, :destroy]
    resources :aspect_feedbacks, only:[:update]
    member do
      scope '/profile_photo' do
        put 'approve', to: 'sadhak_profiles#profile_photo_approve'
        put 'reject', to: 'sadhak_profiles#profile_photo_reject'
      end
      get :related_sadhak_profiles
      get :created
    end
    collection do
      get :sadhak_profile_token_verification
      get :resend_sadhak_profile_verification_token
      get :resend_edit_sadhak_profile_verification_token
      post :verify_token_create_sadhak_profile
      patch :verify_token_update_email_and_mobile
      get 'capture_picture'
      post 'verify_picture'
      get 'generate_card'
      post 'selected/profile_photo/approve', to: 'sadhak_profiles#approve_selected'
      post 'selected/profile_photo/reject', to: 'sadhak_profiles#reject_selected'
      get 'search_for_rc_user'
      get 'users_for_provider_login'
      post 'verify_user_for_provider_login'
      scope :validate do
        get :validate_user_name
      end
      get :forgot_syid
      get :search_syid_by_mobile_or_email
      get :search_syid_by_details
    end
  end

  resources :sadhak_profile_steps do
    collection do
      get :delete_other_spiritual_association
      get :delete_sadhak_profile_attended_shivir
    end
  end

  resources :payment_refunds, only: [:update] do
    member do
      post :refund
    end
    collection do
      get :registration_changes_report
    end
  end


  resources :event_cancellation_plan_items do
    collection do
      get :find_plan_items
    end
  end

  resources :events, except: [:show, :destroy] do
    resources :event_orders, only: [:create, :show] do
      member do
        get :payment_mode_details
        match :edit_details, via: [:get, :post]
        scope :edit_details do
          get :payment
          get :initiate_refund
          post :payment_refunds
        end
        match :edit_line_items, via: [:get, :post]
        post :edit_before_pay
        get :transfered_events
        post :cancel_registrations
        post :process_event_order_confirmation
        post :process_event_order_details
      end
    end
    resources :sadhak_profiles, only: [] do
      resources :sadhak_profile_steps do
        collection do
          post :create_other_spiritual_association
          post :create_sadhak_profile_attended_shivir
          get :finish_page
        end
      end
      member do
        post :questionnaire_form
      end
    end
    member do
      get :register
      get :photo_approval
      get :export_photo_approval_list
      get :photo_approval_admin
      get :registration_status
      get :application_status
      get :registration_change
      get :registration_invoices
      get :report
      get :transaction
      get :shivir_details
      get :event_status_update
      get :download_questionnaire_report

      scope :shivir_details  do
        get :proposed_category
        get :tax_type
        get :registration_cancelation_policy
        get :registration_discount_plan
        get :cost_estimation_or_budget
        get :payment_gateway_options
        get :awareness
        get :additional_details
      end
    end
    collection do
      get :upcoming_events
      get :event_types
      get :replicate
      scope :shivir_details do
        get :event_discount_plan_associations
        post :edit_discount_plan
      end
      get :show_event_transaction_details
      get :show_event_reg_change_details
      get :show_event_transaction_receipt
      get :show_resend_pre_approval_email
      get :show_payment_refund_amount_modal
      get :show_payment_reject_request_modal
    end

    resources :registration_centers, only: [:new, :edit, :create, :update]

    collection do
      get :autocomplete
      get :event_index
      get :datatables
    end

    resources :sadhak_profiles, only: [] do
      collection do
        get 'event_register_syid_search'
        get 'event_register_forgot_syid'
        get 'edit_registration_syid_search'
        get 'edit_registration_forgot_syid'
      end
    end
  end

  get '/sy-clubs/:id', to: redirect('/forums/%{id}')

  resources :sy_clubs, only: [:index, :show, :update, :new, :create], path: "forums" do

    resources :sy_club_steps, only: [:show, :update, :index]

    collection do
      get :nearest_sy_clubs
      get :autocomplete
      get :datatables
      get :sadhak_profile_datatables
      get :verify_board_member
      get :forum_admin
      get :sadhak_non_members
    end

    member do
      get :register
      get :sy_club_register_syid_search
      get :sy_club_register_forgot_syid
      post :verify_members
      post :process_club_members
      get :payment
      get :complete
      get :transfer_complete
      scope "admin" do
        get :members
      end
    end

  end

  resources :sy_clubs, path: 'forums', only: [] do
    resources :digital_assets, path: 'forum_attendance/episodes', only: [] do
      resources :forum_attendance_details, except: [:destroy] do
        put 'update_attendance'
      end
    end
  end
  resources :sy_clubs, path: 'forums' do
    get 'forum_attendance', to: 'forum_attendance_details#forum_attendance'
    collection do
      post 'search_member_from_other_forum', to: 'forum_attendance_details#search_member_from_other_forum'
      post 'absent_members_details', to: 'forum_attendance_details#absent_members_details'
    end
  end

  resources :sy_club_members, only: [] do
    member do
      get :info
    end
  end

  resources :db_states, only:[:index]
  resources :db_cities, only:[:index]

  resources :event_orders, only: [:update] do
    resources :event_order_line_items, only: [:destroy]
    member do
       post :pay
       get :complete
       get :hdfc_complete
       get :pre_approval_complete
      get :update_status
      get :resend_pre_approval_email
      get :resend_transaction_receipt_email
      get :registration_details
      get :confirmation_details
      get :registration_receipt
    end
    collection do
      get :pre_approval_event_application
      get :bulk_update_event_order_status
      get :generate_csv
      get :registration_status
      get :check_registration_exists
    end
  end

  resources :role_dependencies, only: [:create, :destroy, :update]

  resources :order_payment_informations, only: [] do
    collection do
      post :success, to: 'order_payment_informations#paid'
      post :cancel, to: 'order_payment_informations#paid'
      get :redirect
    end
  end

  resources :pg_sy_hdfc_payments, only: [] do
    collection do
      post :success, to: 'pg_sy_hdfc_payments#paid'
      post :cancel, to: 'pg_sy_hdfc_payments#paid'
      get :redirect
    end
  end
end
