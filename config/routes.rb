Rails.application.routes.draw do
  root to: 'pages#about'
  get '/about' => 'pages#about'
  get '/auth/instapaper/callback' => 'sessions#create'
  delete '/aurevoir' => 'sessions#destroy', as: 'logout'
end
