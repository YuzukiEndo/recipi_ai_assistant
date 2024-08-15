Rails.application.routes.draw do
  root 'pages#home'

  get 'how_to_use', to: 'pages#how_to_use'
  get 'terms_of_service', to: 'pages#terms_of_service'
  get 'privacy_policy', to: 'pages#privacy_policy'
  get 'contact', to: 'pages#contact'
  post 'contact', to: 'pages#submit_contact'
  get 'password_resets', to: 'password_resets#new'

  # レシピ関連のルート
  get 'recipe_conditions/new', to: 'recipe_conditions#new', as: 'recipe_conditions_new'
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

  #お気に入り機能
  resources :favorites, only: [:index, :create]

  #パスワードリセット
  resources :password_resets, only: [:new, :create, :edit, :update]
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

end
