namespace :v2 do
  
    resources :sessions, only: [] do
        collection do
           post :sign_in
           get :get_user
        end
    end

    resources :chrome_logs, only: [:create]

    resources :sadhak_profiles, only: [] do
        collection do
            get :send_report
            post :update_downloaded_assets
        end
    end
  
    match '*path', :to => 'base#routing_error', via: :all
  end