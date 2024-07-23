class UsersController < ApplicationController
  # ログイン要求をスキップ（新規登録とユーザー作成アクションのみ）
  skip_before_action :require_login, only: %i[new create]

  # 新規ユーザー登録フォームを表示
  def new
    @user = User.new
  end

  # 新規ユーザーを作成
  def create
    @user = User.new(user_params)
    if @user.save
      # Sorceryのメソッドを使用して自動ログイン
      auto_login(@user)
      # ユーザー作成成功時、ルートパスにリダイレクト
      redirect_to root_path
    else
      # ユーザー作成失敗時、新規登録フォームを再表示
      render :new
    end
  end

  private

  # Strong Parameters: 許可されたパラメータのみを抽出
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
