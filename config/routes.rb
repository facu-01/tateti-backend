Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :players, only: [:index, :create]
  post '/auth/login', to: 'authentication#login'

  resources :games, only: [:index, :create]

  get '/games/show', to: 'games#show'
  post '/games/join', to: 'games#join_game'
  post '/games/move', to: 'games#move'
end
