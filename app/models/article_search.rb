# Represents a search request in the external articles API and its response
class ArticleSearch < Search
    require 'erb'
    include ERB::Util
    attr_reader :articles, :facets, :search_opts

    # Make sure that a record is complete enough to be useful to the user
    def enough_data_exists_in(record)
        return true
    end

    # Create a new search object
    #
    # q:: a query string
    # page:: a page number (can be an int or string)
    # requested_facets:: an array
    # api_connection:: an ApiConnection object or one of its descendants
    def initialize(q, search_field, page, requested_facets = [], api_connection)
        search_fields = {'author' => 'AU', 'title' =>  'TI', 'all_fields' => 'AND', 'subject' => 'SU'}
        @q = q || 'Linn-Benton Community College'
        @search_field = search_field || 'all_fields'
        @search_field_code = search_fields[search_field] || 'AND'
        @page = page
        @api_connection = api_connection
        @articles = Array.new
        @requested_facets = requested_facets.to_a
        @facets = Array.new
    end

    # Assemble the requested filters, search options, and defaults for an article search
    def search_opts
       i = 1
       facet_filters = Array.new
       @requested_facets.each do |facet|
            facet[1].each do |term|
                facet_filters << {'FilterId' => i, 'FacetValues' => [{'Id' => facet[0].gsub(/\s+/, ''), 'Value' => term}]}
                i = i + 1
            end
        end
       return {query: @q, start: (@page - 1), rows: '10', search_field: @search_field, limiters: ['FT:y'], facet_filters: facet_filters}
    end

    # Send the search to the Article API
    def send_search
        records = Array.new

        if @api_connection.ready?
            results = @api_connection.send_search search_opts
	    logger.info("Article API response: #{results}")
            if results.records
                results.records.each do |record|
                    if enough_data_exists_in record
                        current_article = Article.new
                        current_article.extract_data_from record
                        records.push current_article
                    end
                end
                @articles = Kaminari.paginate_array(records, total_count: results.stat_total_hits).page(@page).per(10)

	        if results.facets.respond_to? :each
                    results.facets.each do |facet|
                        items = []
                        facet[:values].take(10).each do |value|
                            items.push(OpenStruct.new hits: value[:hitcount], value: value[:action].gsub(/addfacetfilter\(\w+\:(.*)\)/, '\1').gsub(/\\(\(|\))/, '\1'), label: value[:value])
                        end
			@facets.push(Blacklight::Solr::Response::Facets::FacetField.new facet[:id], items)
                    end
                end
	    end
        end
    end

end
