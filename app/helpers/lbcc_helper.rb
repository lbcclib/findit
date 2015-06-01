module LbccHelper
    include BlacklightHelper
    include ActionView::Helpers::TextHelper
    require 'nokogiri'
    require 'open-uri'
    require 'openlibrary'
    require 'uri'

    EBSCOHOST_API_PREFIX = 'http://eit.ebscohost.com/Services/SearchService.asmx/Search?prof=linncc.main.eitws&pwd=ebs9905&sort=relevance&authType=profile&ipprof=&startrec=1&numrec=10&db=aph&db=agr&db=buh&db=c8h&db=eric&db=zbh&db=hch&db=hxh&db=nfh&db=pbh&db=bwh&db=voh&format=full&query='
    EBSCOHOST_INTERFACE_PREFIX = 'http://ezproxy.libweb.linnbenton.edu:2048/login?url=http://search.ebscohost.com/login.aspx?direct=true&db=aph&db=agr&db=buh&db=c8h&db=eric&db=zbh&db=hch&db=hxh&db=nfh&db=pbh&db=bwh&db=rlh&db=voh&db=nlebk&type=0&site=ehost-live&bquery='
    EBSCO_LINK_RESOLVER_PREFIX = 'http://resolver.ebscohost.com.ezproxy.libweb.linnbenton.edu:2048/openurl/?linksourcecustid=15183&id=doi:'
    PROXY_PREFIX = 'http://ezproxy.libweb.linnbenton.edu:2048/login?url='
     
    HOLDINGS_NS = 'http://open-ils.org/spec/holdings/v1'
    SUPERCAT_URI_PREFIX = 'http://libcat.linnbenton.edu/opac/extras/supercat/retrieve/atom-full/record/'

    def articles_desired()
        return request.parameters[:show_articles] == 'true' ? true : false
    end

    
    def display_article_type(original_string)
        article_type = original_string.capitalize
        unless article_type.include? 'article'
           article_type += ' article'
        end
        return article_type
    end


    def display_access_options(document, context)
    # Context options: show (individual record), index (search results)
        style = ('index' == context) ? 'simple' : 'fancy'
        if document.has? 'eg_tcn_t'
            tcn_value = render_index_field_value(:document => document, :field => 'eg_tcn_t')
            display_library_holdings(tcn_value, style)
        elsif document.has? 'url_fulltext_display'
            url_value = render_index_field_value(:document => document, :field => 'url_fulltext_display')
            display_fulltext_access_link(url_value, style)
        end
    end

    def display_field(label, value, dd_class)
        value = strip(value)
        if value.include? 'http://'
           value = '<a href="' + value + '">' + value + '</a>'
        end
        return '' if '' == value
        dd_class = "blacklight-#{dd_class}" if dd_class
        display_field = <<-EOS
          <dt class=#{dd_class}>#{label}:</dt>
          <dd class=#{dd_class}>#{value}</dd>
        EOS
        return display_field.html_safe
    end

    def display_solr_field(document, solr_fname, label_text='', dd_class=nil)
        label = ""
        display_field = ""
        label = if label_text.length > 0 then label_text end
        if document.has? solr_fname
            display_value = render_index_field_value(:document => document, :field => solr_fname)
            return '' if '' == display_value
            return display_field(label_text, strip(display_value), dd_class)
        end
        return ''
    end

    def display_field_search_link(label, value, dd_class, search_field='all_fields', exact_match=false, link_class)
        if value
            value_arr = []
            case value
                when Array then value_arr = value
                when String then value_arr.push(value)
                else 
                    value_arr = value.to_a
            end
            dd_class = "blacklight-#{dd_class}" if dd_class
            display_string  = <<-EOS
                <dt class=#{dd_class}>#{label}:</dt>
                <dd class=#{dd_class}>#{value_arr.collect{ |value| search_catalog_link(value, value, search_field, link_class, exact_match)}.join('; ') }</dd>
            EOS
            return display_string.html_safe
        end
        return ''
    end

    def display_solr_field_search_link(document, solr_fname, label_text='', dd_class=nil, search_field='all_fields', exact_match=false, link_class=nil)
        label = ""
        display_field = ""
        label = label_text.length > 0 ? label_text : ''

        if document.has? solr_fname
            values = document[solr_fname] 
            return display_field_search_link(label, values, dd_class, search_field, exact_match, link_class)
        end
        return ''
    end 

    def display_fulltext_access_link(url_value, style)
        display_field = <<-EOS
          <a href=#{url_value} class="btn btn-success" role="button" target="_blank">Access this resource</a>
        EOS
        display_field.html_safe
    end

    def display_library_holdings(tcn, style)
        items = fetch_library_holdings(tcn)
        if false == items
            display_library_holdings = 'Ask a librarian for information about this item.'
	elsif 'fancy' == style
            display_library_holdings = '<dl class="dl-horizontal  dl-invert">'
            items.each do |item|
                display_library_holdings = display_library_holdings + '<dt>' + item[:label] + '</dt><dd>' + item[:status] + '</dd>'
            end
        elsif 'simple' == style
            some_item_available = false
            items.each do |item|
                if 'Available' == item[:status] then some_item_available = true end
            end
        if some_item_available
            display_library_holdings = '<a href="http://libcat.linnbenton.edu/eg/opac/record/' + tcn + '?locg=8;detail_record_view=1" class="btn btn-success">Available at the library</a>'
        else
            display_library_holdings = '<a href="http://libcat.linnbenton.edu/eg/opac/place_hold?query=locg=8;detail_record_view=1;hold_target=' + tcn + 'hold_type=T;hold_source_page=/eg/opac/record/'+ tcn + '?query=locg=8&detail_record_view=1" class="btn btn-warning">Place a hold</a>'
        end
    end

        display_library_holdings.html_safe
    end

    def ebscohost_interface_url()
        return EBSCOHOST_INTERFACE_PREFIX + URI.escape(request.parameters[:q])
    end

    def search_catalog_link(text, search_query, search_field, link_class=nil, exact_match=false)
       search_query = "\"#{search_query}\"".html_safe if exact_match 
       link_to text, catalog_index_path(:q => search_query, :search_field => search_field ), :class => link_class
    end


    def fetch_articles()
        articles = []
        @results = Nokogiri::XML(open(URI.escape(EBSCOHOST_API_PREFIX + request.parameters[:q])))
        records = @results.xpath('//rec')
        records.each do |record|
            tmp = {}
            tmp[:title] = record.xpath('.//atl').text
            tmp[:journal] = record.xpath('.//jtl').text
            if record.at('.//ui[@type="doi"]')
                tmp[:url] = URI.escape(EBSCO_LINK_RESOLVER_PREFIX + record.xpath('.//ui[@type="doi"]').text)
            elsif '' != record.at_xpath('.//plink').text
                tmp[:url] = URI.escape(PROXY_PREFIX + record.xpath('.//plink').text)
            elsif '' != record.at_xpath('.//pdfLink').text
                tmp[:url] = URI.escape(PROXY_PREFIX + record.xpath('.//pdfLink').text)
            else
                tmp[:url] = nil
            end
            tmp[:abstract] = record.xpath('.//ab').text
            tmp[:year] = record.xpath('.//pubinfo/dt/@year').text
            tmp[:type] = display_article_type(record.xpath('.//pubtype').text)
            tmp[:authors] = []
            authors = record.xpath('.//au')
            authors.each do |author|
                tmp[:authors].push(author.text)
            end
            articles.push(tmp)
        end
        return articles
    end

    def fetch_library_holdings(tcn)
    # Call number prefixes/suffixes need to be added
        copies = []
        begin
            @metadata = Nokogiri::XML(open(SUPERCAT_URI_PREFIX + tcn.to_s))
        rescue Errno::ECONNREFUSED
           return false
        end
        volumes = @metadata.xpath('//open-ils:volume[@opac_visible="t"][@lib="LBCCLIB"]', 'open-ils' => HOLDINGS_NS)
        volumes.each do |volume|
            label = volume.xpath('./@label').text
            items = volume.xpath('.//open-ils:copy[@opac_visible="t"]', 'open-ils' => HOLDINGS_NS)
            items.each do |item|
                tmp = {}
                tmp[:status] = item.xpath('.//open-ils:status', 'open-ils' => HOLDINGS_NS).text
                tmp[:location] = item.xpath('.//open-ils:location', 'open-ils' => HOLDINGS_NS).text
                tmp[:label] = label
                copies.push(tmp)
            end
        end
        return copies
    end

    def fetch_cover_url(document)
        if document.has? 'isbn_t'
            isbns = document['isbn_t']
            isbns = isbns.kind_of?(Array) ? isbns : isbns.to_a

            olid = ''
            view = Openlibrary::View

            isbns.each do |isbn|
                if view.find_by_isbn('0972540342')
                    book = view.find_by_isbn('0972540342')
                    break
                end
            end
            if defined? book
               return book.thumbnail_url #but we should loop this....
            end
        end
    end

    def snippet options={}
        value = options[:value].join(' ')
        truncate(strip(value), length: 200, separator: ' ')
    end

    def strip(string)
        # Also strip preceeding [ or whitespace
        string.gsub!(/^[\*\[\s]*/, '')
        string.gsub(/[,-:\];\s]*$/, '')
    end


end
