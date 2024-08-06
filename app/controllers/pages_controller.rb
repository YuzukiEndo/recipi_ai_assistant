class PagesController < ApplicationController
  skip_before_action :require_login, only: [:home]

  def how_to_use;end

  def home;end

  def terms_of_service;end

  def privacy_policy;end

  def contact;end
  
  def submit_contact;end
end
