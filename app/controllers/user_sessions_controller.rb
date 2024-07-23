class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      flash[:success] = 'ユーザー認証に成功しました。健康維持のための指示に従ってください。'
      redirect_to root_path
    else
      flash[:danger] = 'ユーザー認証に失敗しました。不適切な入力データです。再試行してください。'
      redirect_to login_path
    end
  end

  def destroy
    logout
    flash[:success] = '安全に接続を切断しました。次回の認証まで機能が制限されます。'
    redirect_to root_path, status: :see_other
  end
end
