# frozen_string_literal: true

require 'spec_helper'

describe BentoController do
  it '#search_action_url returns a url within the bento controller' do
    options = { q: 'research topic',
                search_field: 'all_fields' }
    expect(controller.search_action_url(options)).to include('/search?')
  end

  it 'can identify when article results are more promising' do
    controller.instance_variable_set :@num_article_hits, 185_683
    controller.instance_variable_set :@num_catalog_hits, 0
    expect(controller.article_results_are_more_promising?).to be true
    expect(controller.catalog_results_are_more_promising?).to be false
  end
  it 'can identify when catalog (Solr) results are more promising' do
    controller.instance_variable_set :@num_article_hits, 2
    controller.instance_variable_set :@num_catalog_hits, 83
    expect(controller.catalog_results_are_more_promising?).to be true
    expect(controller.article_results_are_more_promising?).to be false
  end
end
