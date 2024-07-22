class PagesController < ApplicationController
  # ホームページへのアクセスには認証を必要としない
  skip_before_action :require_login, only: [:home]
  
  # トップページ（ホーム）のアクション
  def home

  end
end
