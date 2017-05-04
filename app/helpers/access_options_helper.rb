# Methods that help show users how they can access materials from the Library
module AccessOptionsHelper
    include BlacklightHelper
    require 'nokogiri'
    require 'open-uri'
    require 'uri'

    # Display how a user can access the resource described in the solr document,
    # whether through a physical library copy or a URL
    def display_access_options document
        mode = mode_of_access document
        if mode
            if 'library_holdings' == mode
                if document['eg_tcn_t'].is_a? Array
                    display_full_library_holdings document['eg_tcn_t'].first
		else
                    display_full_library_holdings document['eg_tcn_t']
                end
            elsif 'url' == mode
                return display_fulltext_access_link document['url_fulltext_display'][0]
            end
        end
    end

    # Briefly display how a user can access the resource described in the solr document,
    # whether through a physical library copy or a URL
    #
    # This is well suited for the search results display page
    def display_concise_access_options document
        mode = mode_of_access document
        if mode
            if 'library_holdings' == mode
                if document['eg_tcn_t'].is_a? Array
                    display_simple_library_holdings document['eg_tcn_t'].first
		else
                    display_simple_library_holdings document['eg_tcn_t']
                end
            elsif 'url' == mode
                return display_fulltext_access_link document['url_fulltext_display'][0]
            end
        end
    end

    private

    # Return a bootstrap button that links to the given value
    def display_fulltext_access_link url
        return link_to('Access this resource', URI.encode(url), class: 'btn btn-success', role: 'button', target: '_blank')
    end

    def mode_of_access document
        if document.has? 'eg_tcn_t'
            return 'library_holdings'
        elsif document.has? 'url_fulltext_display'
            return 'url'
        else
            return false
        end
    end
end
