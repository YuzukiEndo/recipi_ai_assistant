class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      flash[:success] = 'ユーザー認証に成功しました。健康維持のための指示に従ってください。'
      redirect_to root_path
    else
      flash.now[:danger] = '認証失敗。不適切な入力データです。再試行してください。'
      render :new
    end
  end

  def destroy
    logout
    flash[:success] = 'ユーザーセッション終了。再認証までアクセス権限が制限されます。'
    redirect_to root_path, status: :see_other
  end
end
