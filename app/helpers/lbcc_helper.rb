module LbccHelper
    include BlacklightHelper
    include ActionView::Helpers::TextHelper
    include RepresentativeImageHelper
    require 'nokogiri'
    require 'open-uri'
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


    def create_bibtex(document)
       bibtex = '@book{resource, '
       if document.has? 'author_display'
          bibtex.concat('author = {' + document['author_display'].gsub(/[0-9\-]/, '') + '},')
       end
       bibtex.concat('title = {' + document['title_display'] + '}')
       bibtex.concat('}')
       return bibtex
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

    def generate_citations(document)
       if document.has? 'bibtex_t'
          if document['bibtex_t'].is_a?(Array)
             b = BibTeX.parse(document['bibtex_t'][0])
          elif document['bibtex_t'].is_a?(String)
             b = BibTeX.parse(document['bibtex_t'])
          else
             # this is weird, because is_a?(String) or respond_to?(to_str) aren't working
             b = BibTeX.parse(document['bibtex_t'].to_s)
          end
       else
          b = BibTeX.parse(create_bibtex(document))
       end
       styles = Hash.new
       citations = Hash.new
       styles['APA'] = CiteProc::Processor.new format: 'html', style: 'apa'
       styles['MLA'] = CiteProc::Processor.new format: 'html', style: 'modern-language-association'
       styles['Chicago'] = CiteProc::Processor.new format: 'html', style: 'chicago-fullnote-bibliography'
       styles['IEEE'] = CiteProc::Processor.new format: 'html', style: 'ieee'
       styles['CBE'] = CiteProc::Processor.new format: 'html', style: 'council-of-science-editors'
       styles.each do |shortname, processor|
          processor.import b.to_citeproc
          unless processor.empty?
             citations[shortname] = processor.render(:bibliography, id: 'resource').first
          else
             #citations[shortname] = 'Citations not available at this time'
             citations[shortname] = document['bibtex_t']
          end
       end
       return citations
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
        volumes = @metadata.xpath('//open-ils:volume[@opac_visible="t" and @deleted="f"][@lib="LBCCLIB"]', 'open-ils' => HOLDINGS_NS)
        volumes.each do |volume|
            label = volume.xpath('./@label').text
            items = volume.xpath('.//open-ils:copy[@opac_visible="t" and @deleted="f"]', 'open-ils' => HOLDINGS_NS)
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
