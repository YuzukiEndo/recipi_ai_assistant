Rails.application.routes.draw do
  root 'pages#home'

  # レシピ関連のルート
  get 'recipe_conditions/new', to: 'recipe_conditions#new'
  post 'recipe_conditions', to: 'recipe_conditions#create'

  resources :recipes, only: [:show] do
    collection do
      get 'result'  # レシピ生成完了画面用
    end
  end

  # ユーザー関連のルート
  resources :users, only: %i[new create]
  get 'signup', to: 'users#new'

  # セッション関連のルート
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
end
