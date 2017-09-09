# Methods that help figure out what formats the user is interested in
#
# Doesn't really help with views at all, so this should move
module FormatHelper
    include BlacklightHelper

    # Return true if both articles and solr results should be shown
    def show_all_formats?
        return request.parameters[:show_articles] == 'true' ? true : false
    end

    # Return true if only articles should be shown
    def show_only_articles?
        return request.parameters[:show_articles] == 'only' ? true : false
    end

    # Return true if articles should be shown, whether or not solr results
    # should be shown
    def show_articles?
        if (request.parameters.has_key?(:show_articles))
            return request.parameters[:show_articles] == 'false' ? false : true
	else
	    return false
	end
    end
end
