class ArticlesController < CatalogController

  include BlacklightRangeLimit::ControllerOverride

  def index
    if has_search_parameters?
      @page = params[:page].present? ? Integer(params[:page]) : 1
      @q = params[:q] || 'Linn-Benton Community College'
      search_fields = {'author' => 'AU', 'title' =>  'TI', 'all_fields' => 'AND', 'subject' => 'SU'}
      @search_field = params[:search_field] || 'all_fields'
      @search_field_code = search_fields[@search_field] || 'KW'
      @requested_facets = params[:f] || []

      connection = EdsService.get_valid_connection session
      results = connection.search search_opts
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
    raw_article = connection.retrieve dbid: params[:db], an: params[:id]
    @document = Article.new raw_article
  end

  private

  # Assemble the requested filters, search options, and defaults for an article search
  def search_opts
    i = 1
    facet_filters = Array.new
    @requested_facets.each do |key, values|
      values.each do |value|
        facet_filters << {'FilterId' => i, 'FacetValues' => [{'Id' => key.gsub(/\s+/, ''), 'Value' => value}]}
        i = i + 1
      end
    end
    return {query: @search_field_code + ':' + @q, start: (@page - 1), rows: '10', search_field: @search_field, limiters: ['FT:y'], facet_filters: facet_filters}
  end
end
