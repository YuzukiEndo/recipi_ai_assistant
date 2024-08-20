class UserMailer < ApplicationMailer
  def reset_password_email(user)
    @user = user
    @url = edit_password_reset_url(@user.reset_password_token, host: 'utopia-app-20240808-f76c709c579e.herokuapp.com')
    mail(to: user.email, subject: "パスワードリセット")
  end
end