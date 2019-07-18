Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    resources :bookings, only: [:index, :create, :show, :update, :destroy]
    resources :users, only: [:index, :create, :show, :update, :destroy]
    resources :flights, only: [:index, :create, :show, :update, :destroy]
    resources :companies, only: [:index, :create, :show, :update, :destroy]
  end
end
