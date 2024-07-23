class ApplicationController < ActionController::Base
  # 全てのアクションの前にユーザーのログイン状態を確認
  before_action :require_login

  # 全てのアクションの前にセッションの有効期限をチェック
  before_action :check_session_expiration

  private

  # ユーザーが認証されていない場合の処理
  def not_authenticated
    # ログインページにリダイレクト
    redirect_to login_path
  end

  # セッションの有効期限をチェックするメソッド
  def check_session_expiration
    # ユーザーがログイン中で、最後のアクセスから60分以上経過している場合
    if logged_in? && session[:last_seen] && session[:last_seen] < 60.minutes.ago
      # ユーザーをログアウトさせる
      logout
      # ログインページにリダイレクト
      redirect_to login_path
    else
      # 最後のアクセス時間を更新
      session[:last_seen] = Time.current
    end
  end
end