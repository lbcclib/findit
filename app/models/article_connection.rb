# Connect to an external API to get some articles
class ArticleConnection
  # Create an initial connection to the API
  def initialize
  end

  # Make sure the API is ready to accept queries
  def ready?
  end

  # Fetch a single article from the external API
  def retrieve_single_article db, id
    puts db + id
  end

  # Send the search to the Article API
  def send_search search_opts
    puts search_opts
  end

end
