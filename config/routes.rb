Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: :json } do
    # get :last_updated, controller: :home
    resources :home, only: [:index]
    resources :facilities, only: [:index, :show]
    resources :zones, only: [:index]
  end

  namespace :admin do
    resources :dashboard, only: [:index, :show]
    resources :facilities do
      resources :services, only: [:create, :update, :destroy], controller: :facility_services
      resources :welcomes, only: [:create, :destroy], controller: :facility_welcomes
    end
  end
end
