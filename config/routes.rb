Rails.application.routes.draw do
  get 'embed' => 'embeds#show'

  root to: 'pages#home'
  get '/about' => 'pages#about'
  get '/auth/instapaper/callback' => 'sessions#create'
  delete '/aurevoir' => 'sessions#destroy', as: 'logout'
  get '/folders/:slug' => 'folders#show', as: 'folder'
end
