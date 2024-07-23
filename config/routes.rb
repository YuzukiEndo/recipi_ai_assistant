Rails.application.routes.draw do
  root 'pages#home'
  
  resources :users, only: %i[new create]
  
  get 'signup', to: 'users#new'
  

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  get '/logout', to: 'user_sessions#destroy', as: :logout
  delete 'logout', to: 'user_sessions#destroy'
end
