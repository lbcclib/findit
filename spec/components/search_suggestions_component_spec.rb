# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchSuggestionsComponent, type: :component do
  it 'knows cinahl is a database' do
    expected = { name: 'cinahl', exact: true,
                 url: 'https://ezproxy.libweb.linnbenton.edu/login?url='\
                      'https://search.ebscohost.com/login.aspx?authtype=ip,uid&profile=health&defaultdb=c8h' }
    expect(SearchSuggestionsComponent.new(query: 'cinahl').best_bet).to eq(expected)
  end

  it 'can generate a query url in cinahl' do
    expected = { name: 'cinahl', exact: false,
                 url: 'https://search-ebscohost-com.ezproxy.libweb.linnbenton.edu/login.aspx?direct=true&db=c8h&bquery='\
                      'myocardial infarction&type=1&searchMode=And&site=ehost-live' }
    expect(SearchSuggestionsComponent.new(query: 'cinahl myocardial infarction').best_bet).to eq(expected)
  end

  it 'does not provide a database when none match' do
    expect(SearchSuggestionsComponent.new(query: 'oregon history').best_bet).to eq(nil)
  end
end
