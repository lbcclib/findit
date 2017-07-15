# Displays real-time availability information from the ILS
module LibraryHoldingsHelper

    # Returns an HTML representation of the library's holdings attached to a bib record identified by tcn parameter
    def display_simple_library_holdings tcn
        display_library_holdings = ''
        stat = get_status tcn
        if stat
            if stat.any_copies_available?
                display_library_holdings.concat('<a href="http://libcat.linnbenton.edu/eg/opac/record/'+ tcn.to_s + '?locg=8;detail_record_view=1" target="_blank" class="btn btn-success">Available at the library</a>')
                display_library_holdings.concat('<table class="table"><thead><tr><th>Status</th><th>Library</th><th>Location</th><th>Call number</th></thead>')
                stat.copies.first(5).each do |copy|
                    display_library_holdings.concat copy_information_table_row copy
                end
                display_library_holdings.concat('</table>')
            else
                display_library_holdings = '<a href="http://libcat.linnbenton.edu/eg/opac/place_hold?query=locg=8;detail_record_view=1;hold_target=' + tcn.to_s + 'hold_type=T;hold_source_page=/eg/opac/record/'+ tcn.to_s + '?query=locg=8&detail_record_view=1" class="btn btn-warning" target="_blank">Place a hold</a>'
            end
        else
            display_library_holdings.concat 'Ask a librarian for information about this item.'
        end
	return display_library_holdings.html_safe
    end

    def display_full_library_holdings tcn
        display_library_holdings = ''
        stat = get_status tcn
        if stat
            display_library_holdings = '<h2>Find a copy on the shelf</h2>'
            stat.copies.each do |item|
                display_library_holdings.concat copy_information_defined_list item
                display_library_holdings.concat '<hr />'
            end
        else
            display_library_holdings.concat 'Ask a librarian for information about this item.'
        end
	return display_library_holdings.html_safe
    end

    private
    def url_for_evergreen_hold tcn
        return 'https://libcat.linnbenton.edu/eg/opac/place_hold?query=locg=8;detail_record_view=1;hold_target=' + tcn.to_s + ';hold_type=T'
    end

    def url_for_evergreen_record tcn
        return 'http://libcat.linnbenton.edu/eg/opac/record/'+ tcn.to_s + '?locg=8;detail_record_view=1'
    end

    def get_status tcn
        if session[:evergreen_connection]
            stat = session[:evergreen_connection].get_holdings tcn, org_unit: 1, descendants: true
            if stat.copies.size > 0
                return stat
            end
        end
        return false
    end
    def copy_information_table_row copy
        return content_tag :tr, content_tag(:td, copy.status) + content_tag(:td, copy.owning_lib) + content_tag(:td, copy.location) + content_tag(:td, copy.call_number)
    end
    def copy_information_defined_list copy
        return content_tag :dl, 
            content_tag(:dt, 'Status') + content_tag(:dd, copy.status) +
            content_tag(:dt, 'Library') + content_tag(:dd, copy.owning_lib) +
            content_tag(:dt, 'Location') + content_tag(:dd, copy.location) +
            content_tag(:dt, 'Call number') + content_tag(:dd, copy.call_number), 
            class: 'dl-horizontal dl-invert'
    end
    

end
