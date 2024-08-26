Rails.application.routes.draw do
  get 'oauths/oauth'
  get 'oauths/callback'
  get 'nutrition_logs/index'
  get 'nutrition_logs/create'
  root 'pages#home'

  get 'how_to_use', to: 'pages#how_to_use'
  get 'terms_of_service', to: 'pages#terms_of_service'
  get 'privacy_policy', to: 'pages#privacy_policy'
  get 'contact', to: 'pages#contact'
  post 'contact', to: 'pages#submit_contact'
  get 'password_resets', to: 'password_resets#new'
  post '/callback', to: 'line_bot#callback'

  post "oauth/callback" => "oauths#callback"
  get "oauth/callback" => "oauths#callback"
  get "oauth/:provider" => "oauths#oauth", as: :auth_at_provider

  # レシピ関連のルート
  get 'recipe_conditions/new', to: 'recipe_conditions#new', as: 'recipe_conditions_new'
  post 'recipe_conditions', to: 'recipe_conditions#create'

  get 'recipes/:id/line_share', to: 'recipes#line_share', as: 'line_share_recipe'

  get 'recipes/:id/share_twitter', to: 'recipes#share_twitter', as: 'share_twitter_recipe'

  resources :recipes, only: [:show] do
    collection do
      get 'result'  # レシピ生成完了画面用
    end
  end

  # ユーザー関連のルート
  resources :users, only: [:new, :create]
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'

  # セッション関連のルート
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
  get 'logout', to: 'user_sessions#destroy'

  #お気に入り機能
  resources :favorites, only: [:index, :create]

  #パスワードリセット
  resources :password_resets, only: [:new, :create, :edit, :update]
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  #栄養価保存
  resources :nutrition_logs, only: [:new, :create, :index]

end
