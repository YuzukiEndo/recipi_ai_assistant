class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      auto_login(@user)
      flash[:success] = '登録が完了しました。健康維持のための指示に従ってください。'
      redirect_to root_path
    else
      flash.now[:danger] = '登録失敗。不適切な入力データです。再試行してください。'
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end