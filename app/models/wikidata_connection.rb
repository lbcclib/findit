# frozen_string_literal: true

USER_AGENT = 'LBCC library (libref@linnbenton.edu) Ruby 2.6'

require 'sparql/client'

# A connection to Wikidata
class WikidataConnection
  def initialize
    @client = SPARQL::Client.new(
      'https://query.wikidata.org/sparql',
      method: :post,
      headers: { 'User-Agent': USER_AGENT }
    )
  end

  def query(query)
    @client.query(query).map(&:to_h)
  rescue Errno::ECONNREFUSED, Net::OpenTimeout
    {}
  end
end
