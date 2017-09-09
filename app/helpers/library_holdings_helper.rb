# Displays real-time availability information from the ILS
module LibraryHoldingsHelper
    private
    def url_for_evergreen_hold tcn
        return 'https://libcat.linnbenton.edu/eg/opac/place_hold?query=locg=8;detail_record_view=1;hold_target=' + Array.wrap(tcn).first.to_s + ';hold_type=T'
    end

    def url_for_evergreen_record tcn
        return 'http://libcat.linnbenton.edu/eg/opac/record/'+ Array.wrap(tcn).first.to_s + '?locg=8;detail_record_view=1'
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
