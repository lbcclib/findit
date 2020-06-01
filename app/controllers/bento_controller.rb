# frozen_string_literal: true

# This controller is responsible for the Bento results presentation,
# which shows the user search results from Solr AND the articles API
class BentoController < ApplicationController
  helper_method :no_results?
  def index
    if params[:q]
      @q = params[:q]
      redirect_to_desired_controller
      article_results
      solr_results
      redirect_to_most_useful_controller
    else
      redirect_to action: 'home'
    end
  end

  def search_action_url(options = nil)
    opt = (options || {}).merge(action: 'index', controller: 'bento')
    url_for opt
  end

  def home; end

  def article_results
    connection = EdsService.get_valid_connection session
    search_fields = { 'author' => 'AU:', 'title' => 'TI:', 'all_fields' => '', 'subject' => 'SU:' }
    search_field = params[:search_field] || 'all_fields'
    search_field_code = search_fields[@search_field] || ''
    results = ArticleSearch.send connection, page: 1, q: @q, search_field_code: search_field_code, num_rows: 3

    @articles = []
    @num_article_hits = results.stat_total_hits

    results.records&.each do |record|
      current_article = Article.new record
      @articles.push current_article
    end
  end

  def solr_results
    catalog_search = Blacklight::SearchService.new config: CatalogController.blacklight_config, user_params: { page: 1, per_page: 3, q: @q }
    solr, @catalog_records = catalog_search.search_results
    logger.debug "Bento search: catalog records received: #{@catalog_records.inspect}"
    @catalog_format_facets = Hash[*solr['facet_counts']['facet_fields']['format']]
    @num_catalog_hits = solr['response']['numFound']
  end

  # If the user passed along some params that indicate they might just want articles or catalog,
  # show them that instead.
  def redirect_to_desired_controller
    redirect_to controller: 'articles', params: request.query_parameters if user_desired_articles?
    redirect_to controller: 'catalog', params: request.query_parameters if user_desired_catalog?
  end

  def user_desired_articles?
    params[:showArticles] && !params[:showCatalog]
  end

  def user_desired_catalog?
    params[:showCatalog] && !params[:showArticles]
  end

  # If we only got results from one data source, redirect to that one
  def redirect_to_most_useful_controller
    redirect_to controller: 'articles', params: request.query_parameters if only_have_article_results?
    redirect_to controller: 'catalog', params: request.query_parameters if only_have_catalog_results?
  end

  def only_have_article_results?
    @num_article_hits.positive? && @num_catalog_hits.zero?
  end

  def only_have_catalog_results?
    @num_catalog_hits.positive? && @num_article_hits.zero?
  end

  def no_results?
    @num_article_hits.zero? && @num_catalog_hits.zero?
  end
end
