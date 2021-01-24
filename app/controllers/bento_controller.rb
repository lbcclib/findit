# frozen_string_literal: true

# This controller is responsible for the Bento results presentation,
# which shows the user search results from Solr AND the articles API
class BentoController < ApplicationController
  helper_method :no_results?
  def index
    if params[:q].blank?
      redirect_to root_url, notice: t('bento.needs_query')
    else
      @q = params[:q]
      redirect_to_desired_controller
      article_results
      solr_results
      redirect_to_most_useful_controller
    end
  end

  def search_action_url(options = nil)
    opt = (options || {}).merge(action: 'index', controller: 'bento')
    url_for opt
  end

  def home; end

  def article_results
    params[:view] = 'title'
    params[:results_per_page] = 3
    results = EdsService.blacklight_style_search params
    @num_article_hits = results.stat_total_hits
    @articles = results.records&.map { |record| Article.new record }
  end

  def solr_results
    search_config = {
      config: CatalogController.blacklight_config,
      user_params: { page: 1, per_page: 3, q: @q }
    }
    catalog_search = Blacklight::SearchService.new search_config
    @response, @catalog_records = catalog_search.search_results
    logger.debug "Bento search: catalog records received: #{@catalog_records.inspect}"
    @catalog_format_facets = Hash[*@response['facet_counts']['facet_fields']['format']]
    @num_catalog_hits = @response['response']['numFound']
    @evergreen_service = EvergreenService.new
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
    redirect_to controller: 'articles', params: request.query_parameters if article_results_are_more_promising?
    redirect_to controller: 'catalog', params: request.query_parameters if catalog_results_are_more_promising?
  end

  def article_results_are_more_promising?
    @num_article_hits > 100 && @num_catalog_hits.zero?
  end

  def catalog_results_are_more_promising?
    @num_catalog_hits.positive? && @num_article_hits < 5
  end

  def no_results?
    @num_article_hits.zero? && @num_catalog_hits.zero?
  end
end
