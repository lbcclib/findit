class ApplicationController < ActionController::Base

  require 'ebsco-discovery-service-api'
  require 'openssl'

  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller
  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :create_article_api_session
  after_filter :track_action

  protected

  def track_action
    if Rails.env.production?
      ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters
      ahoy.track_visit
    end
  end

  def create_article_api_session
    if 'eds' == Rails.configuration.articles['api']
      @connection = EDSApi::ConnectionHandler.new(2)
      if Rails.configuration.articles['username'].nil? or Rails.configuration.articles['password'].nil?
        @connection.ip_init 'edsapi'
        @connection.ip_authenticate
      else
        @connection.uid_init(
          Rails.configuration.articles['username'],
          Rails.configuration.articles['password'],
          'edsapi')
        @connection.uid_authenticate
      end
      @connection.create_session
      session[:article_api_connection] = @connection
    elsif 'worldcat' == Rails.configuration.articles['api']
    else
      session[:article_api_connection] = 0
    end
  end

end
