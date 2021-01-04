Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  mount ActionCable.server => '/cable'

  devise_for :users, skip: [:password], controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  resources :users, only: [:edit] do
    collection do
      post :request_reset_password
      get :user_confirm_verification_code
      put :verify_verification_code_and_reset_password
      get :resend_user_verification_code
      put :update_password
      get :forgot_password
    end
  end

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

  comfy_route :cms_admin, path: "/cms_admin"
  comfy_route :cms, path: "/cms"

  comfy_route :blog_admin, path: "/cms_admin"
  comfy_route :blog, path: "blog"

  # Api for chrome
  draw :chrome

  draw :api

  draw :v2
  draw :v1

  root to: 'homes#index'

  get "/home" => "homes#index"

  get '/dashboard', to: 'ember#index'

  # match '*path', to: 'application#routing_error', constraints: lambda{|request| !request.path.include?('any_login') }, via: :all
end
