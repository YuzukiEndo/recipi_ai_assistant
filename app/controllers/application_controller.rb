class ApplicationController < ActionController::Base
  before_action :require_login, except: [:home, :new, :how_to_use, :privacy_policy, :contact, :terms_of_service]
  before_action :set_cache_headers

  def redirect_if_logged_in
    redirect_to root_path if logged_in?
  end
  
  private

  def not_authenticated
    redirect_to login_path
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end