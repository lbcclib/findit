class ArticleConnection
  # Create an initial connection to the API
  def initialize
    @raw_connection = :@eds_connection
    @auth_method = :ip
    if using_eds?
      @eds_connection = EDSApi::ConnectionHandler.new(2)
      if using_uid_auth?
        @auth_method = :uid
        @eds_connection.uid_init(
          Rails.configuration.articles['username'],
          Rails.configuration.articles['password'],
          'edsapi')
        @eds_connection.uid_authenticate
      else
        @eds_connection.ip_init 'edsapi'
        @eds_connection.ip_authenticate
      end
      @eds_connection.create_session
    end
  end

  def ready?
    if :@eds_connection == @raw_connection
      if @eds_connection.show_session_token and @eds_connection.show_auth_token
        return true
      end
      return false
    end
  end

  def retrieve_single_article db, id
    if :@eds_connection == @raw_connection
      if @auth_method = :uid
        return @eds_connection.retrieve db, id, '', '', @eds_connection.show_session_token, @eds_connection.show_auth_token
      else
        return @eds_connection.retrieve db, id
      end
    end
  end

  def send_search search_opts
    if :@eds_connection == @raw_connection
      if @auth_method = :uid
        begin
          return @eds_connection.search search_opts, @eds_connection.show_session_token, @eds_connection.show_auth_token
        rescue ActionView::Template::Error, Net::ReadTimeout
          logger.debug "EDS timed out"
          return false
        end
      else
        begin
          return @eds_connection.search search_opts
        rescue ActionView::Template::Error, Net::ReadTimeout
          logger.debug "EDS timed out"
          return false
        end
      end
    end
  end

  private

  def using_eds?
    return 'eds' == Rails.configuration.articles['api']
  end

  def using_uid_auth?
    if Rails.configuration.articles['username'].nil? or Rails.configuration.articles['password'].nil?
      return false
    end
    return true
  end

  def using_worldcat?
    return 'worldcat' == Rails.configuration.articles['api']
  end

end
