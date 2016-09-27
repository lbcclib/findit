# Methods that help show users how they can access materials from the Library
module AccessOptionsHelper
    include BlacklightHelper
    require 'nokogiri'
    require 'open-uri'
    require 'uri'

    # Display how a user can access the resource described in the solr document,
    # whether through a physical library copy or a URL
    def display_access_options document
        access_option document, 'fancy'
    end

    # Briefly display how a user can access the resource described in the solr document,
    # whether through a physical library copy or a URL
    #
    # This is well suited for the search results display page
    def display_concise_access_options document
        access_option document, 'simple'
    end

    private
    def display_fulltext_access_link url_value
        return link_to 'Access this resource', url_value, class: 'btn btn-success', role: 'button', target: '_blank'
    end

    def access_option document, style
        if document.has? 'eg_tcn_t'
            tcn_value = render_index_field_value(:document => document, :field => 'eg_tcn_t')
            display_library_holdings(tcn_value, style)
        elsif document.has? 'url_fulltext_display'
            url_value = render_index_field_value(:document => document, :field => 'url_fulltext_display')
            display_fulltext_access_link url_value
        end
    end
end
