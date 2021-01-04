namespace :v1 do

  resources :sadhak_profiles, only: [:show]

  resources :sy_club_user_roles, only: [:index]
  
  resources :sy_clubs, only: [:show]

  resources :sessions, only: [] do
  	collection do
     	get :current
     	get :sign_out
     	post :sign_in
     	get :basic_user_details
  	end
  end
  
  resources :digital_assets, only: [:index, :show] do 
  	member do
  		get :download
  	end
    collection do
      get :virtual_shivir_digital_assets
      get :forum_digital_assets
    end
  end

  resources :collections, only: [:index, :show] do
  end

  match '*path', :to => 'base#routing_error', via: :all
end
