module AccessOptionsHelper
    include BlacklightHelper
    require 'nokogiri'
    require 'open-uri'
    require 'uri'

    def display_access_options(document, context)
    # Context options: show (individual record), index (search results)
        style = ('index' == context) ? 'simple' : 'fancy'
        if document.has? 'eg_tcn_t'
            tcn_value = render_index_field_value(:document => document, :field => 'eg_tcn_t')
            display_library_holdings(tcn_value, style)
        elsif document.has? 'url_fulltext_display'
            url_value = render_index_field_value(:document => document, :field => 'url_fulltext_display')
            display_fulltext_access_link url_value, :style => style
        end
    end


    def display_fulltext_access_link url_value, opts={}
        access_link = <<-EOS
          <a href=#{url_value} class="btn btn-success" role="button" target="_blank">Access this resource</a>
        EOS
        return access_link.html_safe
    end
end
