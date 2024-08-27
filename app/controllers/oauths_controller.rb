class OauthsController < ApplicationController
  skip_before_action :require_login

  def oauth
    login_at(auth_params[:provider])
  end

  def callback
    provider = auth_params[:provider]
    if @user = login_from(provider)
      Rails.logger.info "User logged in: #{@user.inspect}"
      Rails.logger.info "Session: #{session.to_h}"
      flash[:success] = "認証に成功しました。健康維持のための指示に従ってください。"
      redirect_to root_path
    else
      begin
        @user = create_from(provider)
        auto_login(@user)
        flash[:success] = '認証に成功しました。健康維持のための指示に従ってください。'
        redirect_to root_path
      rescue
        flash[:danger] = "認証失敗。Googleアカウントでのログインに失敗しました"
        redirect_to root_path
      end
    end
  end

  private

  def auth_params
    params.permit(:code, :provider)
  end
end