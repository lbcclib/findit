class ArticlesController < CatalogController

  include BlacklightRangeLimit::ControllerOverride

  def index
    if has_search_parameters?
      page = params[:page].present? ? Integer(params[:page]) : 1
      q = params[:q] || 'Linn-Benton Community College'
      search_fields = {'author' => 'AU', 'title' =>  'TI', 'all_fields' => 'AND', 'subject' => 'SU'}
      search_field = params[:search_field] || 'all_fields'
      search_field_code = search_fields[@search_field] || 'AND'
      requested_facets = params[:f] || []

      connection = EdsService.get_valid_connection session
      results = ArticleSearch.send connection, page: page, q: q, search_field: search_field, search_field_code: search_field_code, requested_facets: requested_facets, num_rows: 10
      records = []
      @facets = []

      if results.records
        results.records.each do |record|
          current_article = Article.new record
          records.push current_article
        end
        @articles = Kaminari.paginate_array(records, total_count: results.stat_total_hits).page(@page).per(10)

        if results.facets.respond_to? :each
          results.facets.each do |facet|
            items = []
            facet[:values].take(10).each do |value|
              items.push(OpenStruct.new hits: value[:hitcount], value: value[:action].gsub(/addfacetfilter\(\w+\:(.*)\)/, '\1').gsub(/\\(\(|\))/, '\1'), label: value[:value])
            end
	    new_facet = Blacklight::Solr::Response::Facets::FacetField.new facet[:id], items
            @facets << new_facet
          end
        end
      end
    end
  end

  def show
    connection = EdsService.get_valid_connection session
    raw_article = connection.retrieve dbid: params[:db], an: CGI.unescape(params[:id])
    @document = Article.new raw_article
  end

end
