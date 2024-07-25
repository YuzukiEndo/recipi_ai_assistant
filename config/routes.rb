Rails.application.routes.draw do
  root 'pages#home'

  # レシピ関連のルート
  get 'recipe_conditions/new', to: 'recipe_conditions#new'
  post 'recipe_conditions', to: 'recipe_conditions#create'

  #条件選択のルート
  get 'ingredients/index'
  get 'ingredients/show'
  get 'categories/index'
  get 'categories/show'
  
  # ユーザー関連のルート
  resources :users, only: %i[new create]
  get 'signup', to: 'users#new'

  # セッション関連のルート
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  get '/logout', to: 'user_sessions#destroy', as: :logout
  delete 'logout', to: 'user_sessions#destroy'
end
