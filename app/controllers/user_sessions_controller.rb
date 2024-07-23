class UserSessionsController < ApplicationController
  # ログイン要求をスキップ（ログインフォーム表示とログイン処理のみ）
  skip_before_action :require_login, only: %i[new create]

  def new
  end

  # ログイン処理を実行
  def create
    @user = login(params[:email], params[:password])

    if @user
      # ログイン成功時、ルートパスにリダイレクト
      redirect_to root_path
    else
      # ログイン失敗時、ログインフォームを再表示
      render :new
    end
  end

  # ログアウト処理
  def destroy
    logout
    redirect_to root_path, status: :see_other
  end
end
