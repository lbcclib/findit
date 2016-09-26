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
  before_filter :start_jruby_pg
  after_filter :track_action

  protected

  def track_action
    if Rails.env.production?
      ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters
      ahoy.track_visit
    end
  end

  def create_article_api_session
    session[:article_api_connection] = ArticleConnection.new
  end

  def start_jruby_pg
    if Rails.env.production? and ( RUBY_PLATFORM =~ /jruby/ or RUBY_PLATFORM =~ /java/ )
      require 'jdbc/postgres'
      Jdbc::Postgres.load_driver
    end
  end

end
