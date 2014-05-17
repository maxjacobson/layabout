Rails.application.routes.draw do
  root to: 'pages#about'
  get '/about' => 'pages#about'
end
