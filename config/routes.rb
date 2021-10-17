Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: :json } do
    # get :last_updated, controller: :home
    # get :home, controller: :home
    resources :home, only: [:index]
    resources :facilities, only: %i[index show]
    resources :zones, only: [:index]
  end

  namespace :admin do
    resources :dashboard, only: %i[index show]

    resources :facilities do
      resources :schedules, only: %i[new create edit update], controller: :facility_schedules
      resources :time_slots, only: %i[new create destroy], controller: :facility_time_slots
      resources :services, only: %i[create update destroy], controller: :facility_services
      resources :welcomes, only: %i[create destroy], controller: :facility_welcomes
    end
  end
end
