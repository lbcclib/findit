# frozen_string_literal: true

SUGGESTIONS = [
  {
    string: 'cinahl',
    exact_url: 'https://ezproxy.libweb.linnbenton.edu/login?url=https://search.ebscohost.com/login.aspx?authtype=ip,uid&profile=health&defaultdb=c8h',
    generated_url_prefix: 'https://search-ebscohost-com.ezproxy.libweb.linnbenton.edu/login.aspx?direct=true&db=c8h&bquery=',
    generated_url_suffix: '&type=1&searchMode=And&site=ehost-live'
  }
].freeze

# Offers suggestions to the user based on their query and the results
class SearchSuggestionsComponent < ViewComponent::Base
  def initialize(query: nil, response: nil)
    super
    @query = query
    @response = response
  end

  def best_bet
    return nil unless @query

    # try exact match
    match = SUGGESTIONS.detect { |suggestion| @query.strip == suggestion[:string] }
    return { name: match[:string], url: match[:exact_url], exact: true } if match

    # try an inexact match
    match = SUGGESTIONS.detect { |suggestion| @query.include? suggestion[:string] }
    return nil unless match

    { name: match[:string],
      url: match[:generated_url_prefix] + @query.sub(match[:string], '').strip + match[:generated_url_suffix],
      exact: false }
  end
end
