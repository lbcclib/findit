module ArticleHelper
    require 'nokogiri'
    require 'open-uri'
    require 'ruby_eds.rb'
    require 'uri'

    include RubyEDS

    EBSCO_LINK_RESOLVER_PREFIX = 'http://resolver.ebscohost.com.ezproxy.libweb.linnbenton.edu:2048/openurl/?linksourcecustid=15183&id=doi:'
    PROXY_PREFIX = 'http://ezproxy.libweb.linnbenton.edu:2048/login?url='
     
    def display_article_type(original_string)
        article_type = original_string.capitalize
        unless article_type.include? 'article'
           article_type += ' article'
        end
        return article_type
    end

    def display_article_field(label, value, dc_element='description')
        value = strip(value)
        return value if '' == value
        field_for_display = <<-EOS
            <dt>#{label}:</dt>
            <dd propery="#{dc_element}">#{value}</dd>
        EOS
        return field_for_display.html_safe
    end

    def fetch_search_data()
        if !session[:article_user_token].blank? && !session[:article_session_token].blank?
            page_number = params[:page].present? ? params[:page] : 1
            begin
                raw_response = search([request.parameters[:q]], session[:article_session_token], session[:article_user_token], 'xml', 'limiter' => 'FT:y', 'resultsperpage' => 10, 'view' => 'detailed', 'facetfilter' => '1, SourceType:Academic Journals, SourceType:News', 'pagenumber' => page_number, 'highlight' => 'n' )
	    rescue
                return false
	    end
            results = Nokogiri::XML(raw_response.body)
            results.remove_namespaces!
            return results
        end
        return false
    end

    def extract_record_list(results)
        test = results.xpath('//Record')
        return test
    end

    def extract_data_from_single_record(record)
        data = {}
        if record.at_xpath('./PLink') and record.at_xpath('./RecordInfo/BibRecord/BibEntity/Titles/Title/TitleFull')
            data[:title] = record.xpath('./RecordInfo/BibRecord/BibEntity/Titles/Title/TitleFull').text
            data[:journal] = record.at_xpath('.//IsPartOf/BibEntity/Titles/Title/TitleFull').text
            data[:url] = PROXY_PREFIX + record.xpath('./PLink').text
            data[:abstract] = record.xpath('./Items/Item[Name/text()="Abstract"]/Data').text
            data[:year] = record.xpath('.//Date[Type/text()="published"]/Y').text
            data[:type] = 'Article'
            data[:authors] = []
            authors = record.xpath('.//PersonEntity')
            authors.each do |author|
                data[:authors].push(author.xpath('.//NameFull').text)
            end
        end
        return data
    end

    def perform_article_search()
        articles = []
        results = fetch_search_data()
	if results
            list_of_records = extract_record_list(results)
            list_of_records.each do |record|
                if !extract_data_from_single_record(record).empty?
                    articles.push(extract_data_from_single_record(record))
                end
            end
	end
	return articles
    end

end
