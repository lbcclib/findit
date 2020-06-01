# frozen_string_literal: true

require 'spec_helper'

describe BentoController do
  it '#search_action_url returns a url within the bento controller' do
    options = { q: 'research topic',
                search_field: 'all_fields' }
    expect(controller.search_action_url(options)).to include('/search?')
  end

  it 'can identify when only articles match the search query' do
    controller.instance_variable_set :@num_article_hits, 185_683
    controller.instance_variable_set :@num_catalog_hits, 0
    expect(controller.only_have_article_results?).to be true
    expect(controller.only_have_catalog_results?).to be false
  end
  it 'can identify when only catalog (Solr) docs match the search query' do
    controller.instance_variable_set :@num_article_hits, 0
    controller.instance_variable_set :@num_catalog_hits, 83
    expect(controller.only_have_catalog_results?).to be true
    expect(controller.only_have_article_results?).to be false
  end
end
