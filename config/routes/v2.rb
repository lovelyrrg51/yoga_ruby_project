namespace :v2, path: '/' do
  root 'home#index'
  resources :blogs, only: [:show, :index, :create]
  resources :digital_contents, only: [:index, :show]
  resources :digital_content_accesses, only: [:index]
  resources :user_forum_subscriptions, only: [:index, :show]
  resources :user_registered_events, only: [:index, :show]

  resources :forums_request, only: [:create]
  resources :forums, path: :forum, except: [:create] do
    member do
      get :register, controller: 'forum_wizard'
      post :verify_members, controller: 'forum_wizard'
      post :process_club_members, controller: 'forum_wizard'
      get :complete
      get :transfer_complete
    end
  end

  resources :event_orders do
    collection do
      get :registration_status
      get :check_registration_exists
    end
    member do
      get :registration_details
      get :confirmation_details
      post :cancel_registrations
      get :initiate_refund
      post :payment_refunds
      match :upgrade_downgrade, via: [:get, :post]
      match :edit_details, via: [:get, :post]
      get :transfered_events
      post :process_event_order_confirmation
      post :process_event_order_details
      get :payment
      post :pay
      get :complete
      get :hdfc_complete
      get :pre_approval_complete
      post :resend_transaction_receipt_email
      get :registration_receipt
    end
  end

  post 'batch_regist', controller: 'batch_sadhak_profiles'
  post '/find_sadhak_profile', to: 'find_sadhak_profiles#find'
  post '/create_email_subscription', to: 'home#create_email_subscription'

  resources :events do
    collection do
      get :upcoming
    end
    resources :event_seatings, only: :index
    resources :event_orders, only: [:create, :show] do
    end
    member do
      post :verify_member, controller: 'event_wizard'
    end
  end

  resources :sadhak_profiles do
    get :family_profiles, on: :collection
    resource :verify_sadhak_profile, only: :show do
      patch :verify
      patch :resend
      patch :send_email_verification
      patch :send_mobile_verification
    end
  end
  resources :avatars, only: :create

  resource :forgot_syid, only: :show do
    post :search_by_email
    post :search_by_mobile
    post :search_by_details
  end

  resources :countries, only: [:index] do
    resources :states, only: [:index] do
      resources :cities, only: [:index]
    end
  end

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

  match :forum, to: 'forums#index', via: [:get, :post]

  resources :teachers, only: [:index, :show]

  get 'what_is_shivyog', to: 'about_us#what_is_shivyog'
  get '/our_story', to: 'pages#our_story'
  get '/our_teacher', to: 'pages#our_teacher'
  get '/our_teacher_detail', to: 'pages#our_teacher_detail'
  get '/shivyog_foundation', to: 'pages#shivyog_foundation'
  get '/contributions', to: 'pages#contributions'
  get '/seva_projects', to: 'pages#seva_projects'
  get '/dr_shivanand', to: 'pages#dr_shivanand'
  get '/awards_recognitions', to: 'pages#awards_recognitions'
  get '/about_shivyog_events', to: 'pages#about_shivyog_events'
  get '/shivyog_dharma', to: 'pages#shivyog_dharma'
  get '/cosmic_farming', to: 'pages#cosmic_farming'
  get '/cosmic_medicine', to: 'pages#cosmic_medicine'
  get '/what_are_sy_forums', to: 'pages#what_are_sy_forums'
  get '/seva_through_forums', to: 'pages#seva_through_forums'
  get '/act_now', to: 'pages#act_now'
  get '/shivyog_faqs', to: 'pages#shivyog_faqs'
  get '/contributions', to: 'pages#contributions'
  get '/seva_projects', to: 'pages#seva_projects'
  get '/watch', to: 'pages#watch'
  get '/read', to: 'pages#read'
  get '/quotes', to: 'pages#quotes'
  get '/contact', to: 'pages#contact'
end
