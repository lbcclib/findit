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

    # Return a bootstrap button that links to the given value
    def display_fulltext_access_link url
        #return link_to 'Access this resource', 'http://ezproxy.libweb.linnbenton.edu:2048/login?url=http://digital.films.com/PortalPlaylists.aspx?e=1&xtid=68370&aid=4065&cid=1639_path', class: 'btn btn-success', role: 'button', target: '_blank'
        return link_to('Access this resource', URI.encode(url), class: 'btn btn-success', role: 'button', target: '_blank')
    end

    def access_option document, style
        if document.has? 'eg_tcn_t'
            tcn_value = document['eg_tcn_t']
            display_library_holdings(tcn_value, style)
        elsif document.has? 'url_fulltext_display'
            display_fulltext_access_link document['url_fulltext_display'][0]
        end
    end
end
