# Connect to an external API to get some articles
class EdsConnection < ArticleConnection
  # Create an initial connection to the API
  def initialize
    @auth_method = :ip
    @raw_connection = EDSApi::ConnectionHandler.new(2)
    if using_uid_auth?
      @auth_method = :uid
      @raw_connection.uid_init(
        Rails.configuration.articles['username'],
        Rails.configuration.articles['password'],
        'edsapi')
      @raw_connection.uid_authenticate
    else
      begin
        @raw_connection.ip_init 'edsapi'
        @raw_connection.ip_authenticate
      rescue NoMethodError
      end
    end
    @raw_connection.create_session
  end

  def ready?
    if @raw_connection.show_session_token and @raw_connection.show_auth_token
      return true
    end
    return false
  end

  # Fetch a single article from the external API
  def retrieve_single_article db, id
    if @auth_method == :uid
      return @raw_connection.retrieve db, id, '', '', @raw_connection.show_session_token, @raw_connection.show_auth_token
    else
      return @raw_connection.retrieve db, id
    end
  end

  def send_search search_opts
    if @auth_method == :uid
      begin
        return @raw_connection.search search_opts, @raw_connection.show_session_token, @raw_connection.show_auth_token
      rescue ActionView::Template::Error, Net::ReadTimeout
        return handle_timeout
      end
    else
      begin
        return @raw_connection.search search_opts
      rescue ActionView::Template::Error, Net::ReadTimeout
        return handle_timeout
      end
    end
  end

  def using_uid_auth?
    if Rails.configuration.articles['username'].nil? or Rails.configuration.articles['password'].nil?
      return false
    else
      return true
    end
  end

  private

  def handle_timeout
    logger.debug "EDS timed out"
    return false
  end

end
