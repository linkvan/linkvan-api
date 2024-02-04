Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    # root to: "admin/dashboard#index", as: :authenticated_root
    root to: redirect("admin/dashboard"), as: :authenticated_root
  end

  root to: redirect("/users/sign_in")

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: :json } do
    resources :facilities, only: %i[index show]
    resources :notices, param: :slug, only: %i[index show]
    resources :zones, only: [:index]
    resources :home, only: [:index]
  end

  namespace :admin do
    root to: "admin/dashboard#index"

    resources :dashboard, only: %i[index show] do
      collection do
        get :heatmap, defaults: { format: :json }
        get :timeseries, defaults: { format: :json }
        get :districts, defaults: { format: :json }
      end
    end

    # resources :users, only: [] do
      # root to: "dashboard#index"
    # end

    resources :users do
      resources :passwords, only: %i[new create]
    end

    resources :facilities do
      resources :schedules, only: %i[new create edit update], controller: :facility_schedules
      resources :time_slots, only: %i[new create destroy], controller: :facility_time_slots
      resources :services, only: %i[create update destroy], controller: :facility_services
      resources :welcomes, only: %i[create destroy], controller: :facility_welcomes
    end

    resources :alerts
    resources :notices
  end
end
