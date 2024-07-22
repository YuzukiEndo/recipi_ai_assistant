class ApplicationController < ActionController::Base
  # 全てのアクションの前にユーザーのログイン状態を確認
  before_action :require_login

  private

  # ユーザーが認証されていない場合の処理
  def not_authenticated
    # ログインページにリダイレクト
    redirect_to login_path
  end
end