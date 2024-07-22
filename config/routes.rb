Rails.application.routes.draw do
  # アプリケーションのルートパス（トップページ）を設定
  root 'pages#home'
  
  # ユーザー関連のルーティング
  resources :users, only: %i[new create]
  
  # カスタムルーティング
  # 新規登録ページへのルート
  get 'signup', to: 'users#new'
  
  # セッション管理（ログイン・ログアウト）のルーティング
  get 'login', to: 'user_sessions#new'      # ログインフォームの表示
  post 'login', to: 'user_sessions#create'  # ログイン処理の実行
  delete 'logout', to: 'user_sessions#destroy' # ログアウト処理の実行
end
