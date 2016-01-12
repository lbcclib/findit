module LbccHelper
    include BlacklightHelper
    include ActionView::Helpers::TextHelper
    require 'nokogiri'
    require 'open-uri'
    require 'uri'

    def show_all_formats?
        return request.parameters[:show_articles] == 'true' ? true : false
    end

    def show_only_articles?
        return request.parameters[:show_articles] == 'only' ? true : false
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


    def display_fulltext_access_link(url_value, style)
        access_link = <<-EOS
          <a href=#{url_value} class="btn btn-success" role="button" target="_blank">Access this resource</a>
        EOS
        return access_link.html_safe
    end

    def snippet opts={}
        if opts[:value].is_a? Array
	    value = opts[:value][0]
        else
	    value = opts[:value]
        end
        return truncate strip(value), length: 200, separator: ' '
    end

    def strip(string)
        # Also strip preceeding [ or whitespace
	if !string.is_a? String
	   string = string.to_s
	end
        string.gsub!(/^[\*\s]*/, '')
        string.gsub!(/[,\-:;\s]*$/, '')
        return string
    end


end
