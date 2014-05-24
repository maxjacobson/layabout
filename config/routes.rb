Rails.application.routes.draw do
  get 'bookmarks/archive'

  get 'bookmarks/like'

  get 'embed' => 'embeds#show'

  root to: 'pages#home'
  get '/about' => 'pages#about'
  get '/auth/instapaper/callback' => 'sessions#create'
  delete '/aurevoir' => 'sessions#destroy', as: 'logout'
  get '/folders/:slug' => 'folders#show', as: 'folder'
  resources :bookmarks, only: [] do
    member do
      put :like
      put :unlike
      put :archive
    end
  end
end
