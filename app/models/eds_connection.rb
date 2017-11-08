# Connect to an external API to get some articles
class EdsConnection < ArticleConnection
  # Create an initial connection to the API
  def initialize
    @raw_connection = EBSCO::EDS::Session.new({
      :user => Rails.configuration.articles['username'],
      :pass => Rails.configuration.articles['password'],
      :profile => 'edsapi'
    })
    @last_authentication = Time.current
  end

  # Make sure the EDS connection has all it needs to send searches
  def ready?
    unless (@last_authentication and @last_authentication > 20.minutes.ago)
      initialize
    end
    return true
  end

  # Fetch a single article from the external API
  def retrieve_single_article db, id
    article_identifiers = {:dbid => db, :an => id}
    return @raw_connection.retrieve(article_identifiers)
  end

  # Send an entire search, and return the JSON data produced by
  # the EDS API
  def send_search search_opts
    begin
      return @raw_connection.search search_opts
    rescue ActionView::Template::Error, Net::ReadTimeout, RuntimeError
      return handle_timeout
    end
  end

  private

  # Respond when EDS times out
  def handle_timeout
    logger.debug "EDS timed out"
    return false
  end

end
