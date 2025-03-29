# config/routes.rb
Rails.application.routes.draw do
  root 'home#index'
  
post '/sign-out', to: 'sessions#destroy'
post '/api/sign-out', to: 'sessions#api_sign_out'
  # Session management
  get 'sessions/after_signup', to: 'sessions#after_signup'
  
  # Members resources
  resources :members do
    collection do
      get :dashboard
    end
    member do
      post :approve
      post :suspend
    end
  end
end