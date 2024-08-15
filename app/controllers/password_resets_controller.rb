class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  def new; end

  def create
    @user = User.find_by_email(params[:email])
    if params[:email].present? && @user
      @user.deliver_reset_password_instructions!
      flash[:success] = 'パスワードリセット手順を記載したメールを送信しました。'
      redirect_to login_path
    else
      flash.now[:danger] = '送信失敗。不適切な入力データです。再試行してください。'
      render :new
    end
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.change_password(params[:user][:password])
      flash[:success] = '更新完了。パスワードが正常に更新されました。'
      redirect_to login_path
    else
      flash.now[:danger] = '更新失敗。パスワードの更新に失敗しました。'
      render :edit
    end
  end
end