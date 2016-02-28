module ArticleHelper
    require 'open-uri'
    require 'uri'

    EBSCO_LINK_RESOLVER_PREFIX = 'http://resolver.ebscohost.com.ezproxy.libweb.linnbenton.edu:2048/openurl/?linksourcecustid=15183&id=doi:'
    PROXY_PREFIX = 'http://ezproxy.libweb.linnbenton.edu:2048/login?url='
     
    def display_article_type(original_string)
        article_type = original_string.capitalize
        unless article_type.include? 'article'
           article_type += ' article'
        end
        return article_type
    end

    def display_article_field(label, value)
        return value if '' == value
        value = strip(value)
        field_for_display = <<-EOS
            <dt>#{label}:</dt>
            <dd>#{value}</dd>
        EOS
        return field_for_display.html_safe
    end

end
