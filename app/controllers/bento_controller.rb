class BentoController < ApplicationController

  def index
    if params[:q]
      @q = params[:q]
      if params[:showArticles] and !params[:showCatalog]
        redirect_to controller: 'articles', params: request.query_parameters
      elsif params[:showCatalog] and !params[:showArticles]
        redirect_to controller: 'catalog', params: request.query_parameters
      else
        connection = EdsService.get_valid_connection session
        search_fields = {'author' => 'AU', 'title' =>  'TI', 'all_fields' => 'AND', 'subject' => 'SU'}
        search_field = params[:search_field] || 'all_fields'
        search_field_code = search_fields[@search_field] || 'AND'
        results = ArticleSearch.send connection, page: 1, q: @q, search_field_code: search_field_code, num_rows: 3 

        @articles = []
        @num_article_hits = results.stat_total_hits

        if results.records
          results.records.each do |record|
            current_article = Article.new record
            @articles.push current_article
          end
        end

        catalog_search = Blacklight::SearchService.new config: CatalogController.blacklight_config, user_params: {page: 1, per_page: 3, q: @q} 
        solr, @catalog_records = catalog_search.search_results
        logger.debug "Bento search: catalog records received: #{@catalog_records.inspect}"
	@catalog_format_facets = Hash[*solr['facet_counts']['facet_fields']['format']]
	@num_catalog_hits = solr['response']['numFound']
      end
    else
      redirect_to action: 'home'
    end
  end

  def home
  end

end
