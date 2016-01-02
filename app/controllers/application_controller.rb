class ApplicationController < ActionController::Base

  # Loads RubyEDS so that to create User sessions
  # for the EDS api
  require 'ruby_eds'
  include RubyEDS


  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller
  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :track_action

  before_action :create_article_api_session

  protected

  def track_action
    ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters
  end

  def create_article_api_session
    session[:article_user_token] = authenticate_user(
      Rails.application.secrets.article_api_username,
      Rails.application.secrets.article_api_password)
    session[:article_session_token] = open_session(
      'edsapi',
      'y',
      session[:article_user_token])
  end
  
end
