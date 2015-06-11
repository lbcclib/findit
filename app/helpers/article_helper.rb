module ArticleHelper
    require 'nokogiri'
    require 'open-uri'
    require 'uri'

    EBSCOHOST_API_PREFIX = 'http://eit.ebscohost.com/Services/SearchService.asmx/Search?prof=linncc.main.eitws&pwd=ebs9905&sort=relevance&authType=profile&ipprof=&startrec=1&numrec=10&db=aph&db=agr&db=buh&db=c8h&db=eric&db=zbh&db=hch&db=hxh&db=nfh&db=pbh&db=bwh&db=voh&format=full&query='
    EBSCOHOST_INTERFACE_PREFIX = 'http://ezproxy.libweb.linnbenton.edu:2048/login?url=http://search.ebscohost.com/login.aspx?direct=true&db=aph&db=agr&db=buh&db=c8h&db=eric&db=zbh&db=hch&db=hxh&db=nfh&db=pbh&db=bwh&db=rlh&db=voh&db=nlebk&type=0&site=ehost-live&bquery='
    EBSCO_LINK_RESOLVER_PREFIX = 'http://resolver.ebscohost.com.ezproxy.libweb.linnbenton.edu:2048/openurl/?linksourcecustid=15183&id=doi:'
    PROXY_PREFIX = 'http://ezproxy.libweb.linnbenton.edu:2048/login?url='
     
    def display_article_type(original_string)
        article_type = original_string.capitalize
        unless article_type.include? 'article'
           article_type += ' article'
        end
        return article_type
    end

    def ebscohost_interface_url()
        return EBSCOHOST_INTERFACE_PREFIX + URI.escape(request.parameters[:q])
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

end
