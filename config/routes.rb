Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: :json } do
    # get :last_updated, controller: :home
    # get :home, controller: :home
    resources :home, only: [:index]
    resources :facilities, only: [:index, :show]
    resources :zones, only: [:index]
  end
end
