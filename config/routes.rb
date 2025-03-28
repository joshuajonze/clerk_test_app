# config/routes.rb
Rails.application.routes.draw do
  root 'home#index'
  
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