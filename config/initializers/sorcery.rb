Rails.application.config.sorcery.submodules = [:reset_password, :external]

Rails.application.config.sorcery.configure do |config|
  config.user_class = 'User'

  config.user_config do |user|
    user.reset_password_mailer = UserMailer
    user.reset_password_expiration_period = 24.hours
    user.stretches = 1 if Rails.env.test?
    user.authentications_class = Authentication
  end

  config.external_providers = [:google]

  config.google.key = ENV['GOOGLE_CLIENT_ID']
  config.google.secret = ENV['GOOGLE_CLIENT_SECRET']
  config.google.callback_url = "http://localhost:3000/oauth/callback?provider=google"
  config.google.user_info_mapping = {email: "email", name: "name"}
end