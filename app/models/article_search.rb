class ArticleSearch < Search
    require 'erb'
    include ERB::Util
    attr_reader :articles

    def enough_data_exists_in(record)
        if record['PLink'] and record['RecordInfo']['BibRecord']['BibEntity']['Titles'].first['TitleFull'] and record['Header']['DbId'] and record['Header']['An']
            return true
        else
            return false
        end
    end


    def initialize(q, page, api_connection)
        @q = q
        @page = page
        @api_connection = api_connection
        @articles = Array.new
    end

    def search_opts
        search_opts = String.new
        search_opts.concat('query-1=' + url_encode(@q))
        search_opts.concat('&limiter=FT:y')
        search_opts.concat('&resultsperpage=10')
        search_opts.concat('&view=detailed')
        search_opts.concat('&facetfilter=' + url_encode('1, SourceType:Academic Journals,SourceType:News'))
        search_opts.concat('&pagenumber=' + @page.to_s)
        search_opts.concat('&highlight=n')
        return search_opts
    end

    def send_search
        records = Array.new

        if @api_connection.show_session_token and @api_connection.show_auth_token
            begin
                results = @api_connection.search search_opts, @api_connection.show_session_token, @api_connection.show_auth_token
            end
            total_results_count = results['SearchResult']['Statistics']['TotalHits']
            list_of_records = results['SearchResult']['Data']['Records']
            list_of_records.each do |record|
                if enough_data_exists_in record
                    current_article = Article.new
                    current_article.extract_data_from_api_response record
                    records.push current_article
                end
            end
            @articles = Kaminari.paginate_array(records, total_count: total_results_count).page(@page).per(10)

        end
        return false
    end

end
