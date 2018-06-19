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
  before_filter :create_evergreen_session
  before_filter :start_jruby_pg

  protected

  # Creates a new connection to the Articles API, unless one already
  # exists.  The connection is stored in the session.
  def create_article_api_session
    unless session.key? :article_api_connection
        if using_eds?
            session[:article_api_connection] = EdsConnection.new
        elsif using_worldcat?
            session[:article_api_connection] = WorldcatConnection.new
        end
    end
  end

  # Creates a new connection to the Evergreen catalog API, unless one already
  # exists.  The connection is stored in the session.
  def create_evergreen_session
    begin
        if session.key? :evergreen_connection
            if session[:evergreen_connection] == nil
                session[:evergreen_connection] = EvergreenHoldings::Connection.new 'http://libcat.linnbenton.edu'
            end
        else
            session[:evergreen_connection] = EvergreenHoldings::Connection.new 'http://libcat.linnbenton.edu'
        end
    rescue CouldNotConnectToEvergreenError, NoCatalogIdProvidedError
        session[:evergreen_connection] = nil
    end
  end

  # Loads the activerecord-jdbc-adapter/driver for postgres if:
  # * the environment is a production one, and
  # * jruby is the ruby platform
  def start_jruby_pg
    if Rails.env.production? and ( RUBY_PLATFORM =~ /jruby/ or RUBY_PLATFORM =~ /java/ )
      require 'jdbc/postgres'
      Jdbc::Postgres.load_driver
    end
  end

  private

  # Check to see if the app is configured to get articles from the
  # EDS API
  def using_eds?
    return 'eds' == Rails.configuration.articles['api']
  end

  # Check to see if the app is configured to get articles from the
  # Worldcat API
  def using_worldcat?
    return 'worldcat' == Rails.configuration.articles['api']
  end


end
