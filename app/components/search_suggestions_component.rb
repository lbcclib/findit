# frozen_string_literal: true

SUGGESTIONS = [
  {
    string: 'artstor',
    exact_url: 'https://ezproxy.libweb.linnbenton.edu/login?url=https://library.artstor.org',
    generated_url_prefix: 'https://library-artstor-org.ezproxy.libweb.linnbenton.edu/#/search/',
    generated_url_suffix: ''
  }, {
    string: 'cinahl',
    exact_url: 'https://ezproxy.libweb.linnbenton.edu/login?url=https://search.ebscohost.com/login.aspx?authtype=ip,uid&profile=health&defaultdb=c8h',
    generated_url_prefix: 'https://search-ebscohost-com.ezproxy.libweb.linnbenton.edu/login.aspx?direct=true&db=c8h&bquery=',
    generated_url_suffix: '&type=1&searchMode=And&site=ehost-live'
  }, {
    string: 'ebsco',
    exact_url: 'https://ezproxy.libweb.linnbenton.edu/login?url=https://search.ebscohost.com/login.aspx?authtype=ip,uid&profile=ehost&defaultdb=a9h',
    generated_url_prefix: 'http://ezproxy.libweb.linnbenton.edu:2048/login?url=https://search.ebscohost.com/login.aspx?direct=true&db=a9h&bquery=',
    generated_url_suffix: '&cli0=FT&clv0=Y&type=0&searchMode=And&site=ehost-live'
  }, {
    string: 'ebookcentral',
    exact_url: 'http://ebookcentral.proquest.com/lib/linnbenton-ebooks/home.action',
    generated_url_prefix: 'https://ebookcentral.proquest.com/lib/linnbenton-ebooks/search.action?query=',
    generated_url_suffix: ''
  }, {
    string: 'flipster',
    exact_url: 'https://ezproxy.libweb.linnbenton.edu/login?url=https://search.ebscohost.com/login.aspx?authtype=cookie,ip,url,uid&custid=linncc&db=eon&profile=eon',
    generated_url_prefix: 'http://search.ebscohost.com.ezproxy.libweb.linnbenton.edu:2048/login.aspx?direct=true&db=eon&bquery=',
    generated_url_suffix: '&type=0&searchMode=Standard&site=eon-live'
  }, {
    string: 'gale',
    exact_url: 'https://ezproxy.libweb.linnbenton.edu/login?url=http://infotrac.galegroup.com/itweb/lbcc?db=AONE',
    generated_url_prefix: 'http://ezproxy.libweb.linnbenton.edu:2048/login?url=https://support.gale.com/widgets/search?q=',
    generated_url_suffix: '&loc=lbcc&id=aone'
  }, {
    string: 'jstor',
    exact_url: 'https://ezproxy.libweb.linnbenton.edu/login?url=https://jstor.org',
    generated_url_prefix: 'https://www-jstor-org.ezproxy.libweb.linnbenton.edu/action/doBasicSearch?Query=',
    generated_url_suffix: '&acc=on&wc=on&fc=off&group=none'
  }, {
    string: 'worldcat',
    exact_url: 'https://ezproxy.libweb.linnbenton.edu/login?url=https://linn.on.worldcat.org/discovery',
    generated_url_prefix: 'https://linn-on-worldcat-org.ezproxy.libweb.linnbenton.edu/search?databaseList=&queryString=',
    generated_url_suffix: ''
  }
].freeze



# Offers suggestions to the user based on their query and the results
class SearchSuggestionsComponent < ViewComponent::Base
  def initialize(query: nil, response: nil)
    super
    @query = query&.downcase&.strip
    @response = response
  end

  def best_bet
    return nil unless @query

    # try exact match
    match = SUGGESTIONS.detect { |suggestion| @query == suggestion[:string] }
    return { name: match[:string], url: match[:exact_url], exact: true } if match

    # try an inexact match
    match = SUGGESTIONS.detect { |suggestion| @query.include? suggestion[:string] }
    return nil unless match

    { name: match[:string],
      url: match[:generated_url_prefix] + @query.sub(match[:string], '').strip + match[:generated_url_suffix],
      exact: false }
  end
end
