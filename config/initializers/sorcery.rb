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
  config.google.callback_url = if Rails.env.production?
    "https://utopia-app-20240808-f76c709c579e.herokuapp.com/oauth/callback?provider=google"
  else
    "http://localhost:3000/oauth/callback?provider=google"
  end
  config.google.user_info_mapping = {email: "email", name: "name"}
end