Rails.application.routes.draw do
  
  resources :movies, only: [:index, :create, :destroy]

  resources :seasons, only: [:index, :create, :destroy] 

  resources :catalog, only: [:index]

  post '/purchase', to: 'purchases#purchase', as: 'purchase'

  get '/profile/library', to: 'users#library', as: 'library'
  
  match '*unmatched', to: 'application#handle_routing_error', via: :all

end
