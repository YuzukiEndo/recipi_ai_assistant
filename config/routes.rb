Rails.application.routes.draw do
  get 'pages/home'
  get 'user_sessions/new'
  get 'user_sessions/create'
  get 'user_sessions/destroy'
  get 'users/new'
  get 'users/create'

  root 'pages#home' #また後で変えるかも
  resources :users, only: %i[new create]

  # ユーザー登録
  get 'signup', to: 'users#new'

  # ログイン・ログアウト
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

end
