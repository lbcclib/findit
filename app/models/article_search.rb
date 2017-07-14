# Represents a search request in the external articles API and its response
class ArticleSearch < Search
    require 'erb'
    include ERB::Util
    attr_reader :articles, :facets, :search_opts

    def enough_data_exists_in(record)
        return true
    end

    # Create a new search object
    #
    # q: a query string
    # page: a page number (can be an int or string)
    # requested_facets: an array
    # api_connection: and ApiConnection object or one of its descendants
    def initialize(q, search_field, page, requested_facets = [], api_connection)
        search_fields = {'author' => 'AU', 'title' =>  'TI', 'all_fields' => 'TX', 'subject' => 'SU'}
        @q = q || 'Linn-Benton Community College'
        @search_field_code = search_fields[search_field] || 'TX'
        @page = page
        @api_connection = api_connection
        @articles = Array.new
        @requested_facets = requested_facets.to_a
        @facets = Array.new
    end

    # Assemble the requested filters, search options, and defaults for an article search
    def search_opts
        search_opts = Array.new
        search_opts << ['query-1', @search_field_code + ':' + @q.gsub(/[[:punct:]]/, '')] # remove punctuation, because EDS responds poorly to it (particularly : and ,)
        search_opts << ['limiter', 'FT:y']
        search_opts << ['resultsperpage', '10']
        search_opts << ['view', 'detailed']
        i = 1
        @requested_facets.each do |facet|
            search_opts << ['facetfilter', (i.to_s + ', ' + facet)]
            i = i + 1
        end
        search_opts << ['pagenumber', @page.to_s]
        search_opts << ['highlight', 'n']
        return search_opts
    end

    def send_search
        records = Array.new

        if @api_connection.ready?
            results = @api_connection.send_search search_opts
            if results.records
                results.records.each do |record|
                    if enough_data_exists_in record
                        current_article = Article.new
                        current_article.extract_data_from record
                        records.push current_article
                    end
                end
                @articles = Kaminari.paginate_array(records, total_count: results.hitcount).page(@page).per(10)

	        if results.facets.respond_to? :each
                    results.facets.each do |facet|
                        tmp = ArticleFacet.new facet['Label']
                        facet[:values].take(10).each do |value|
                            tmp.add_value value[:value], value[:action].sub('addfacetfilter(', '').chop, value[:hitcount]
                        end
                        @facets.push(tmp)
                    end
                end
	    end
        end
    end

end
