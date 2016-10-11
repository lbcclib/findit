# Methods that help figure out what formats the user is interested in
#
# Doesn't really help with views at all, so this should move
module FormatHelper
    include BlacklightHelper

    def show_all_formats?
        return request.parameters[:show_articles] == 'true' ? true : false
    end

    def show_only_articles?
        return request.parameters[:show_articles] == 'only' ? true : false
    end

    def show_articles?
        if (request.parameters.has_key?(:show_articles))
            return request.parameters[:show_articles] == 'false' ? false : true
	else
	    return false
	end
    end
end
